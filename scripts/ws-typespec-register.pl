#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use Term::ReadKey;
use File::Slurp;
use Data::Dumper;
use File::Basename;
use Bio::KBase::workspace::Client;

my $DESCRIPTION =
"
NAME
      ws-typespec-register -- register type specifications in KIDL and release them for use

SYNOPSIS
      ws-typespec-register [OPTIONS]

DESCRIPTION
      
      Register and release modules and associated types with the workspace.
      
      -t [FileName], --typespec [FileName]
               specify the name of the typespec file to register
               
      --add [Type1];[Type2]; ...
               specify the set of new types defined in the typespec for registration
      
      --remove [Type1];[Type2]; ...
               specify the set of types to remove from registration
     
      -j, --jsonschema
               if set, when printing results of a registration the new json schema representation
               of the updated objects is also printed out
     
      --commit
               if not set, then registration will only indicate what would have been registered; to
               actually register the typespec (which cannot be undone) you must set this flag.
      
      --release [ModuleName]
               release the specified module, this takes precedence over any other option except help
                         
      -u [UserName], --user  [UserName]
               the user name; required for registration of a typespec
      
      -p [Password], --password [Password]
               user password; if not given, you will be prompted to provide it

      -e [URL], --url [URL]
               the url of the workspace service; optional
      
      -h, --help
               display this help message, ignore all arguments

AUTHOR
     Michael Sneddon (LBL)
     Roman Sutormin (LBL)
     Gavin Price (LBL)
";
      
# first parse options; only one here is help
my $filetype;
my $downloader;
my $outdir;
my $force;
my $longname;
my $module;

my $user;
my $password;
my $url = "http://140.221.84.170:7058";

my $listtypes;

my $typespecFile;
my $typesToAddString;
my $typesToRemoveString;
my $commit;
my $printJsonSchema;

my $releasedModule;
my $owner;
my $all;

my $help;

my $opt = GetOptions (
     
        "typespec|t=s" => \$typespecFile,
        "add=s" => \$typesToAddString,
        "remove=s" => \$typesToRemoveString,
        "commit" => \$commit,
        "jsonschema|j" => \$printJsonSchema,
        "release=s" => \$releasedModule,
        "user|u=s" => \$user,
        "password|p=s" => \$password,
        "url|e=s" => \$url,
        "help|h" => \$help,
        );

# print help if requested
if(defined($help)) {
     print $DESCRIPTION;
     exit 0;
}

my $ws;
if (defined($user)) {
     if (!defined($password)) { $password = get_pass(); }
     $ws = Bio::KBase::workspace::Client->new($url,user_id=>$user,password=>$password);
} else {
     print STDERR "User name is required to register type specifications.\n";
     print STDERR "Rerun with --help for usage information\n";
     exit 1;
}


my $n_args = $#ARGV+1;
if($n_args==0) {
     if (defined($releasedModule)) {
          #user wants to release a module
          my $releasedTypes;
          eval { $releasedTypes = $ws->release_module($releasedModule); };
          if($@) {
               print STDERR "Error in releasing a module.\n";
               print STDERR $@->{message}."\n";
               if(defined($@->{status_line})) {print STDERR $@->{status_line}."\n" };
               print STDERR "\n";
               exit 1;
          }
          print STDOUT "The following types have been released to the specified version:\n";
          foreach my $typeName (@$releasedTypes) {
               print STDOUT "\t".$typeName."\n";
          }
     } elsif (defined($typespecFile)) {
           # make sure it exists
          if (-e $typespecFile) {
               my $content = read_file( $typespecFile );
               
               my $typesToAdd = [];
               if (defined($typesToAddString)) {
                    my @givenTypes = split(/;/,$typesToAddString);
                    $typesToAdd = \@givenTypes;
               }
               my $typesToRemove = [];
               if (defined($typesToRemoveString)) {
                    my @givenTypes = split(/;/,$typesToRemoveString);
                    $typesToRemove = \@givenTypes;
               }
               
               # setup the input parameters
               my $registerTypespecOptions = {
                              spec => $content,
                              dryrun => 1,
                              new_types => $typesToAdd,
                              remove_types => $typesToRemove
                              };
               if (defined($commit)) {
                    $registerTypespecOptions->{dryrun} = 0;
               }
               
               # do the registration
               my $releasedTypes;
               eval { $releasedTypes = $ws->compile_typespec($registerTypespecOptions); };
               if($@) {
                    print STDERR "Error in registering a module.\n";
                    print STDERR $@->{message}."\n";
                    if(defined($@->{status_line})) {print STDERR $@->{status_line}."\n" };
                    print STDERR "\n";
                    exit 1;
               }
               
               #display the results
               my @releasedTypeNames = sort(keys(%$releasedTypes));
               if($registerTypespecOptions->{dryrun}) {
                    print STDOUT "If this registration is committed, the following types would be updated to:\n"
               } else {
                    print STDOUT "The following types have been registered:\n"
               }
               foreach my $typename (@releasedTypeNames) {
                    print STDOUT "\t".$typename."\n";
                    if(defined($printJsonSchema)) {
                         my $schemaContent = $releasedTypes->{$typename};
                         $schemaContent =~ s/\n/\n\t\t/g;
                         print STDOUT "\t  SCHEMA:\n\t\t".$schemaContent."\n";
                    }
               }
          }
          else {
               print  STDERR "File '$typespecFile' does not exist.\n";
               exit 1;
          }
     
         
     
     
     } else {
          # No options given, so just list the modules owned by this user
          my $listOptions = {owner=>$user};
          my $moduleList;
          eval { $moduleList = $ws->list_modules($listOptions); };
          if($@) {
               print STDERR "Error in listing modules:\n";
               print STDERR $@->{message}."\n";
               if(defined($@->{status_line})) {print STDERR $@->{status_line}."\n" };
               print STDERR "\n";
               exit 1;
          }
          print STDOUT "You are the owner of the following modules:\n";
          foreach my $moduleName (@$moduleList) {
               print STDOUT "\t".$moduleName."\n";
          }
     }
     
} else {
     print STDERR "Too many input arguments.  Rerun with --help for usage.\n";
     exit 1;
}
exit 0;

  



# copied from kbase-login...
sub get_pass {
    my $key  = 0;
    my $pass = ""; 
    print "Password: ";
    ReadMode(4);
    while ( ord($key = ReadKey(0)) != 10 ) {
        # While Enter has not been pressed
        if (ord($key) == 127 || ord($key) == 8) {
            chop $pass;
            print "\b \b";
        } elsif (ord($key) < 32) {
            # Do nothing with control chars
        } else {
            $pass .= $key;
            print "*";
        }
    }
    ReadMode(0);
    print "\n";
    return $pass;
}