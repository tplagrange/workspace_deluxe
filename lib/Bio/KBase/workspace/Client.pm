package Bio::KBase::workspace::Client;

use JSON::RPC::Client;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;
use Bio::KBase::AuthToken;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

Bio::KBase::workspace::Client

=head1 DESCRIPTION


The workspace service at its core is a storage and retrieval system for 
typed objects. Objects are organized by the user into one or more workspaces.

Features:

Versioning of objects
Data provenenance
Object to object references
Workspace sharing
**Add stuff here***

Notes about deletion and GC

BINARY DATA:
All binary data must be hex encoded prior to storage in a workspace. 
Attempting to send binary data via a workspace client will cause errors.


=cut

sub new
{
    my($class, $url, @args) = @_;
    
    if (!defined($url))
    {
	$url = 'http://kbase.us/services/workspace/';
    }

    my $self = {
	client => Bio::KBase::workspace::Client::RpcClient->new,
	url => $url,
    };

    #
    # This module requires authentication.
    #
    # We create an auth token, passing through the arguments that we were (hopefully) given.

    {
	my $token = Bio::KBase::AuthToken->new(@args);
	
	if (!$token->error_message)
	{
	    $self->{token} = $token->token;
	    $self->{client}->{token} = $token->token;
	}
    }

    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




=head2 create_workspace

  $metadata = $obj->create_workspace($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.CreateWorkspaceParams
$metadata is a Workspace.workspace_metadata
CreateWorkspaceParams is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	globalread has a value which is a Workspace.permission
	description has a value which is a string
ws_name is a string
permission is a string
workspace_metadata is a reference to a list containing 6 items:
	0: (id) a Workspace.ws_id
	1: (workspace) a Workspace.ws_name
	2: (owner) a Workspace.username
	3: (moddate) a Workspace.timestamp
	4: (user_permission) a Workspace.permission
	5: (globalread) a Workspace.permission
ws_id is an int
username is a string
timestamp is a string

</pre>

=end html

=begin text

$params is a Workspace.CreateWorkspaceParams
$metadata is a Workspace.workspace_metadata
CreateWorkspaceParams is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	globalread has a value which is a Workspace.permission
	description has a value which is a string
ws_name is a string
permission is a string
workspace_metadata is a reference to a list containing 6 items:
	0: (id) a Workspace.ws_id
	1: (workspace) a Workspace.ws_name
	2: (owner) a Workspace.username
	3: (moddate) a Workspace.timestamp
	4: (user_permission) a Workspace.permission
	5: (globalread) a Workspace.permission
ws_id is an int
username is a string
timestamp is a string


=end text

=item Description

Creates a new workspace.

=back

=cut

sub create_workspace
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function create_workspace (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to create_workspace:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'create_workspace');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.create_workspace",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'create_workspace',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method create_workspace",
					    status_line => $self->{client}->status_line,
					    method_name => 'create_workspace',
				       );
    }
}



=head2 get_workspace_metadata

  $meta = $obj->get_workspace_metadata($wsi)

=over 4

=item Parameter and return types

=begin html

<pre>
$wsi is a Workspace.WorkspaceIdentity
$meta is a Workspace.workspace_metadata
WorkspaceIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
ws_name is a string
ws_id is an int
workspace_metadata is a reference to a list containing 6 items:
	0: (id) a Workspace.ws_id
	1: (workspace) a Workspace.ws_name
	2: (owner) a Workspace.username
	3: (moddate) a Workspace.timestamp
	4: (user_permission) a Workspace.permission
	5: (globalread) a Workspace.permission
username is a string
timestamp is a string
permission is a string

</pre>

=end html

=begin text

$wsi is a Workspace.WorkspaceIdentity
$meta is a Workspace.workspace_metadata
WorkspaceIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
ws_name is a string
ws_id is an int
workspace_metadata is a reference to a list containing 6 items:
	0: (id) a Workspace.ws_id
	1: (workspace) a Workspace.ws_name
	2: (owner) a Workspace.username
	3: (moddate) a Workspace.timestamp
	4: (user_permission) a Workspace.permission
	5: (globalread) a Workspace.permission
username is a string
timestamp is a string
permission is a string


=end text

=item Description

Get a workspace's metadata.

=back

=cut

sub get_workspace_metadata
{
    my($self, @args) = @_;

# Authentication: optional

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_workspace_metadata (received $n, expecting 1)");
    }
    {
	my($wsi) = @args;

	my @_bad_arguments;
        (ref($wsi) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"wsi\" (value was \"$wsi\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_workspace_metadata:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_workspace_metadata');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.get_workspace_metadata",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_workspace_metadata',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_workspace_metadata",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_workspace_metadata',
				       );
    }
}



=head2 get_workspace_description

  $description = $obj->get_workspace_description($wsi)

=over 4

=item Parameter and return types

=begin html

<pre>
$wsi is a Workspace.WorkspaceIdentity
$description is a string
WorkspaceIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
ws_name is a string
ws_id is an int

</pre>

=end html

=begin text

$wsi is a Workspace.WorkspaceIdentity
$description is a string
WorkspaceIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
ws_name is a string
ws_id is an int


=end text

=item Description

Get a workspace's description.

=back

=cut

sub get_workspace_description
{
    my($self, @args) = @_;

# Authentication: optional

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_workspace_description (received $n, expecting 1)");
    }
    {
	my($wsi) = @args;

	my @_bad_arguments;
        (ref($wsi) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"wsi\" (value was \"$wsi\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_workspace_description:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_workspace_description');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.get_workspace_description",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_workspace_description',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_workspace_description",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_workspace_description',
				       );
    }
}



=head2 set_permissions

  $obj->set_permissions($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.SetPermissionsParams
SetPermissionsParams is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
	new_permission has a value which is a Workspace.permission
	users has a value which is a reference to a list where each element is a Workspace.username
ws_name is a string
ws_id is an int
permission is a string
username is a string

</pre>

=end html

=begin text

$params is a Workspace.SetPermissionsParams
SetPermissionsParams is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
	new_permission has a value which is a Workspace.permission
	users has a value which is a reference to a list where each element is a Workspace.username
ws_name is a string
ws_id is an int
permission is a string
username is a string


=end text

=item Description

Set permissions for a workspace.

=back

=cut

sub set_permissions
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function set_permissions (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to set_permissions:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'set_permissions');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.set_permissions",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'set_permissions',
					      );
	} else {
	    return;
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method set_permissions",
					    status_line => $self->{client}->status_line,
					    method_name => 'set_permissions',
				       );
    }
}



=head2 get_permissions

  $perms = $obj->get_permissions($wsi)

=over 4

=item Parameter and return types

=begin html

<pre>
$wsi is a Workspace.WorkspaceIdentity
$perms is a reference to a hash where the key is a Workspace.username and the value is a Workspace.permission
WorkspaceIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
ws_name is a string
ws_id is an int
username is a string
permission is a string

</pre>

=end html

=begin text

$wsi is a Workspace.WorkspaceIdentity
$perms is a reference to a hash where the key is a Workspace.username and the value is a Workspace.permission
WorkspaceIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
ws_name is a string
ws_id is an int
username is a string
permission is a string


=end text

=item Description

Get permissions for a workspace.

=back

=cut

sub get_permissions
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_permissions (received $n, expecting 1)");
    }
    {
	my($wsi) = @args;

	my @_bad_arguments;
        (ref($wsi) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"wsi\" (value was \"$wsi\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_permissions:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_permissions');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.get_permissions",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_permissions',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_permissions",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_permissions',
				       );
    }
}



=head2 save_objects

  $meta = $obj->save_objects($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.SaveObjectsParams
$meta is a reference to a list where each element is a Workspace.object_metadata
SaveObjectsParams is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
	objects has a value which is a reference to a list where each element is a Workspace.ObjectSaveData
ws_name is a string
ws_id is an int
ObjectSaveData is a reference to a hash where the following keys are defined:
	type has a value which is a Workspace.type_id
	data has a value which is an UnspecifiedObject, which can hold any non-null object
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	metadata has a value which is a Workspace.usermeta
	provenance has a value which is a reference to a list where each element is a Workspace.ProvenanceAction
	tver has a value which is a Workspace.type_ver
	hidden has a value which is a Workspace.boolean
type_id is a string
obj_name is a string
obj_id is an int
usermeta is a reference to a hash where the key is a string and the value is a string
ProvenanceAction is a reference to a hash where the following keys are defined:
	time has a value which is a Workspace.timestamp
	service has a value which is a string
	service_ver has a value which is an int
	method has a value which is a string
	method_params has a value which is a reference to a list where each element is an UnspecifiedObject, which can hold any non-null object
	script has a value which is a string
	script_ver has a value which is an int
	script_command_line has a value which is a string
	description has a value which is a string
	input_ws_objects has a value which is a reference to a list where each element is a Workspace.ObjectIdentity
	intermediate_incoming has a value which is a reference to a list where each element is a string
	intermediate_outgoing has a value which is a reference to a list where each element is a string
	description has a value which is a string
timestamp is a string
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
obj_ver is an int
obj_ref is a string
type_ver is a string
boolean is an int
object_metadata is a reference to a list containing 9 items:
	0: (objid) a Workspace.obj_id
	1: (name) a Workspace.obj_name
	2: (type) a Workspace.type_string
	3: (create_date) a Workspace.timestamp
	4: (version) an int
	5: (created_by) a Workspace.username
	6: (wsid) a Workspace.ws_id
	7: (chsum) a string
	8: (size) an int
type_string is a string
username is a string

</pre>

=end html

=begin text

$params is a Workspace.SaveObjectsParams
$meta is a reference to a list where each element is a Workspace.object_metadata
SaveObjectsParams is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
	objects has a value which is a reference to a list where each element is a Workspace.ObjectSaveData
ws_name is a string
ws_id is an int
ObjectSaveData is a reference to a hash where the following keys are defined:
	type has a value which is a Workspace.type_id
	data has a value which is an UnspecifiedObject, which can hold any non-null object
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	metadata has a value which is a Workspace.usermeta
	provenance has a value which is a reference to a list where each element is a Workspace.ProvenanceAction
	tver has a value which is a Workspace.type_ver
	hidden has a value which is a Workspace.boolean
type_id is a string
obj_name is a string
obj_id is an int
usermeta is a reference to a hash where the key is a string and the value is a string
ProvenanceAction is a reference to a hash where the following keys are defined:
	time has a value which is a Workspace.timestamp
	service has a value which is a string
	service_ver has a value which is an int
	method has a value which is a string
	method_params has a value which is a reference to a list where each element is an UnspecifiedObject, which can hold any non-null object
	script has a value which is a string
	script_ver has a value which is an int
	script_command_line has a value which is a string
	description has a value which is a string
	input_ws_objects has a value which is a reference to a list where each element is a Workspace.ObjectIdentity
	intermediate_incoming has a value which is a reference to a list where each element is a string
	intermediate_outgoing has a value which is a reference to a list where each element is a string
	description has a value which is a string
timestamp is a string
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
obj_ver is an int
obj_ref is a string
type_ver is a string
boolean is an int
object_metadata is a reference to a list containing 9 items:
	0: (objid) a Workspace.obj_id
	1: (name) a Workspace.obj_name
	2: (type) a Workspace.type_string
	3: (create_date) a Workspace.timestamp
	4: (version) an int
	5: (created_by) a Workspace.username
	6: (wsid) a Workspace.ws_id
	7: (chsum) a string
	8: (size) an int
type_string is a string
username is a string


=end text

=item Description

Save objects to the workspace. Saving over a deleted object undeletes
it.

=back

=cut

sub save_objects
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function save_objects (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to save_objects:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'save_objects');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.save_objects",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'save_objects',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method save_objects",
					    status_line => $self->{client}->status_line,
					    method_name => 'save_objects',
				       );
    }
}



=head2 get_objects

  $data = $obj->get_objects($object_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$object_ids is a reference to a list where each element is a Workspace.ObjectIdentity
$data is a reference to a list where each element is a Workspace.ObjectData
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string
ObjectData is a reference to a hash where the following keys are defined:
	data has a value which is an UnspecifiedObject, which can hold any non-null object
	meta has a value which is a Workspace.object_metadata_full
object_metadata_full is a reference to a list containing 10 items:
	0: (objid) a Workspace.obj_id
	1: (name) a Workspace.obj_name
	2: (type) a Workspace.type_string
	3: (create_date) a Workspace.timestamp
	4: (version) an int
	5: (created_by) a Workspace.username
	6: (wsid) a Workspace.ws_id
	7: (chsum) a string
	8: (size) an int
	9: (metadata) a Workspace.usermeta
type_string is a string
timestamp is a string
username is a string
usermeta is a reference to a hash where the key is a string and the value is a string

</pre>

=end html

=begin text

$object_ids is a reference to a list where each element is a Workspace.ObjectIdentity
$data is a reference to a list where each element is a Workspace.ObjectData
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string
ObjectData is a reference to a hash where the following keys are defined:
	data has a value which is an UnspecifiedObject, which can hold any non-null object
	meta has a value which is a Workspace.object_metadata_full
object_metadata_full is a reference to a list containing 10 items:
	0: (objid) a Workspace.obj_id
	1: (name) a Workspace.obj_name
	2: (type) a Workspace.type_string
	3: (create_date) a Workspace.timestamp
	4: (version) an int
	5: (created_by) a Workspace.username
	6: (wsid) a Workspace.ws_id
	7: (chsum) a string
	8: (size) an int
	9: (metadata) a Workspace.usermeta
type_string is a string
timestamp is a string
username is a string
usermeta is a reference to a hash where the key is a string and the value is a string


=end text

=item Description

Get objects from the workspace.

=back

=cut

sub get_objects
{
    my($self, @args) = @_;

# Authentication: optional

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_objects (received $n, expecting 1)");
    }
    {
	my($object_ids) = @args;

	my @_bad_arguments;
        (ref($object_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"object_ids\" (value was \"$object_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_objects:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_objects');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.get_objects",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_objects',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_objects",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_objects',
				       );
    }
}



=head2 get_object_metadata

  $meta = $obj->get_object_metadata($object_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$object_ids is a reference to a list where each element is a Workspace.ObjectIdentity
$meta is a reference to a list where each element is a Workspace.object_metadata_full
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string
object_metadata_full is a reference to a list containing 10 items:
	0: (objid) a Workspace.obj_id
	1: (name) a Workspace.obj_name
	2: (type) a Workspace.type_string
	3: (create_date) a Workspace.timestamp
	4: (version) an int
	5: (created_by) a Workspace.username
	6: (wsid) a Workspace.ws_id
	7: (chsum) a string
	8: (size) an int
	9: (metadata) a Workspace.usermeta
type_string is a string
timestamp is a string
username is a string
usermeta is a reference to a hash where the key is a string and the value is a string

</pre>

=end html

=begin text

$object_ids is a reference to a list where each element is a Workspace.ObjectIdentity
$meta is a reference to a list where each element is a Workspace.object_metadata_full
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string
object_metadata_full is a reference to a list containing 10 items:
	0: (objid) a Workspace.obj_id
	1: (name) a Workspace.obj_name
	2: (type) a Workspace.type_string
	3: (create_date) a Workspace.timestamp
	4: (version) an int
	5: (created_by) a Workspace.username
	6: (wsid) a Workspace.ws_id
	7: (chsum) a string
	8: (size) an int
	9: (metadata) a Workspace.usermeta
type_string is a string
timestamp is a string
username is a string
usermeta is a reference to a hash where the key is a string and the value is a string


=end text

=item Description

Get object metadata from the workspace.

=back

=cut

sub get_object_metadata
{
    my($self, @args) = @_;

# Authentication: optional

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_object_metadata (received $n, expecting 1)");
    }
    {
	my($object_ids) = @args;

	my @_bad_arguments;
        (ref($object_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"object_ids\" (value was \"$object_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_object_metadata:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_object_metadata');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.get_object_metadata",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_object_metadata',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_object_metadata",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_object_metadata',
				       );
    }
}



=head2 delete_objects

  $obj->delete_objects($object_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$object_ids is a reference to a list where each element is a Workspace.ObjectIdentity
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string

</pre>

=end html

=begin text

$object_ids is a reference to a list where each element is a Workspace.ObjectIdentity
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string


=end text

=item Description

Delete objects. All versions of an object are deleted, regardless of
the version specified in the ObjectIdentity. If an object is already
deleted, no error is thrown.

=back

=cut

sub delete_objects
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function delete_objects (received $n, expecting 1)");
    }
    {
	my($object_ids) = @args;

	my @_bad_arguments;
        (ref($object_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"object_ids\" (value was \"$object_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to delete_objects:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'delete_objects');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.delete_objects",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'delete_objects',
					      );
	} else {
	    return;
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method delete_objects",
					    status_line => $self->{client}->status_line,
					    method_name => 'delete_objects',
				       );
    }
}



=head2 undelete_objects

  $obj->undelete_objects($object_ids)

=over 4

=item Parameter and return types

=begin html

<pre>
$object_ids is a reference to a list where each element is a Workspace.ObjectIdentity
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string

</pre>

=end html

=begin text

$object_ids is a reference to a list where each element is a Workspace.ObjectIdentity
ObjectIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	wsid has a value which is a Workspace.ws_id
	name has a value which is a Workspace.obj_name
	objid has a value which is a Workspace.obj_id
	ver has a value which is a Workspace.obj_ver
	ref has a value which is a Workspace.obj_ref
ws_name is a string
ws_id is an int
obj_name is a string
obj_id is an int
obj_ver is an int
obj_ref is a string


=end text

=item Description

Undelete objects. All versions of an object are undeleted, regardless
of the version specified in the ObjectIdentity. If an object is not
deleted, no error is thrown.

=back

=cut

sub undelete_objects
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function undelete_objects (received $n, expecting 1)");
    }
    {
	my($object_ids) = @args;

	my @_bad_arguments;
        (ref($object_ids) eq 'ARRAY') or push(@_bad_arguments, "Invalid type for argument 1 \"object_ids\" (value was \"$object_ids\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to undelete_objects:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'undelete_objects');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.undelete_objects",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'undelete_objects',
					      );
	} else {
	    return;
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method undelete_objects",
					    status_line => $self->{client}->status_line,
					    method_name => 'undelete_objects',
				       );
    }
}



=head2 delete_workspace

  $obj->delete_workspace($wsi)

=over 4

=item Parameter and return types

=begin html

<pre>
$wsi is a Workspace.WorkspaceIdentity
WorkspaceIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
ws_name is a string
ws_id is an int

</pre>

=end html

=begin text

$wsi is a Workspace.WorkspaceIdentity
WorkspaceIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
ws_name is a string
ws_id is an int


=end text

=item Description

Delete a workspace. All objects contained in the workspace are deleted.

=back

=cut

sub delete_workspace
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function delete_workspace (received $n, expecting 1)");
    }
    {
	my($wsi) = @args;

	my @_bad_arguments;
        (ref($wsi) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"wsi\" (value was \"$wsi\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to delete_workspace:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'delete_workspace');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.delete_workspace",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'delete_workspace',
					      );
	} else {
	    return;
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method delete_workspace",
					    status_line => $self->{client}->status_line,
					    method_name => 'delete_workspace',
				       );
    }
}



=head2 undelete_workspace

  $obj->undelete_workspace($wsi)

=over 4

=item Parameter and return types

=begin html

<pre>
$wsi is a Workspace.WorkspaceIdentity
WorkspaceIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
ws_name is a string
ws_id is an int

</pre>

=end html

=begin text

$wsi is a Workspace.WorkspaceIdentity
WorkspaceIdentity is a reference to a hash where the following keys are defined:
	workspace has a value which is a Workspace.ws_name
	id has a value which is a Workspace.ws_id
ws_name is a string
ws_id is an int


=end text

=item Description

Undelete a workspace. All objects contained in the workspace are
undeleted, regardless of their state at the time the workspace was
deleted.

=back

=cut

sub undelete_workspace
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function undelete_workspace (received $n, expecting 1)");
    }
    {
	my($wsi) = @args;

	my @_bad_arguments;
        (ref($wsi) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"wsi\" (value was \"$wsi\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to undelete_workspace:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'undelete_workspace');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.undelete_workspace",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'undelete_workspace',
					      );
	} else {
	    return;
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method undelete_workspace",
					    status_line => $self->{client}->status_line,
					    method_name => 'undelete_workspace',
				       );
    }
}



=head2 request_module_ownership

  $obj->request_module_ownership($mod)

=over 4

=item Parameter and return types

=begin html

<pre>
$mod is a Workspace.modulename
modulename is a string

</pre>

=end html

=begin text

$mod is a Workspace.modulename
modulename is a string


=end text

=item Description

Request ownership of a module name.

=back

=cut

sub request_module_ownership
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function request_module_ownership (received $n, expecting 1)");
    }
    {
	my($mod) = @args;

	my @_bad_arguments;
        (!ref($mod)) or push(@_bad_arguments, "Invalid type for argument 1 \"mod\" (value was \"$mod\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to request_module_ownership:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'request_module_ownership');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.request_module_ownership",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'request_module_ownership',
					      );
	} else {
	    return;
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method request_module_ownership",
					    status_line => $self->{client}->status_line,
					    method_name => 'request_module_ownership',
				       );
    }
}



=head2 compile_typespec

  $return = $obj->compile_typespec($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.CompileTypespecParams
$return is a reference to a hash where the key is a Workspace.type_string and the value is a Workspace.jsonschema
CompileTypespecParams is a reference to a hash where the following keys are defined:
	spec has a value which is a Workspace.typespec
	mod has a value which is a Workspace.modulename
	new_types has a value which is a reference to a list where each element is a Workspace.typename
	remove_types has a value which is a reference to a list where each element is a Workspace.typename
	dependencies has a value which is a reference to a hash where the key is a Workspace.modulename and the value is a Workspace.spec_version
	dryrun has a value which is a Workspace.boolean
typespec is a string
modulename is a string
typename is a string
spec_version is a string
boolean is an int
type_string is a string
jsonschema is a string

</pre>

=end html

=begin text

$params is a Workspace.CompileTypespecParams
$return is a reference to a hash where the key is a Workspace.type_string and the value is a Workspace.jsonschema
CompileTypespecParams is a reference to a hash where the following keys are defined:
	spec has a value which is a Workspace.typespec
	mod has a value which is a Workspace.modulename
	new_types has a value which is a reference to a list where each element is a Workspace.typename
	remove_types has a value which is a reference to a list where each element is a Workspace.typename
	dependencies has a value which is a reference to a hash where the key is a Workspace.modulename and the value is a Workspace.spec_version
	dryrun has a value which is a Workspace.boolean
typespec is a string
modulename is a string
typename is a string
spec_version is a string
boolean is an int
type_string is a string
jsonschema is a string


=end text

=item Description

Compile a new typespec or recompile an existing typespec. 
Also see the release_types function.

=back

=cut

sub compile_typespec
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function compile_typespec (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to compile_typespec:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'compile_typespec');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.compile_typespec",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'compile_typespec',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method compile_typespec",
					    status_line => $self->{client}->status_line,
					    method_name => 'compile_typespec',
				       );
    }
}



=head2 release_types

  $types = $obj->release_types($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.ReleaseTypesParams
$types is a reference to a list where each element is a Workspace.type_string
ReleaseTypesParams is a reference to a hash where the following keys are defined:
	mod has a value which is a Workspace.modulename
	type has a value which is a Workspace.type_id
	types has a value which is a reference to a list where each element is a string
modulename is a string
type_id is a string
type_string is a string

</pre>

=end html

=begin text

$params is a Workspace.ReleaseTypesParams
$types is a reference to a list where each element is a Workspace.type_string
ReleaseTypesParams is a reference to a hash where the following keys are defined:
	mod has a value which is a Workspace.modulename
	type has a value which is a Workspace.type_id
	types has a value which is a reference to a list where each element is a string
modulename is a string
type_id is a string
type_string is a string


=end text

=item Description

Release a type or types.

=back

=cut

sub release_types
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function release_types (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to release_types:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'release_types');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.release_types",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'release_types',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method release_types",
					    status_line => $self->{client}->status_line,
					    method_name => 'release_types',
				       );
    }
}



=head2 list_modules

  $modules = $obj->list_modules()

=over 4

=item Parameter and return types

=begin html

<pre>
$modules is a reference to a list where each element is a Workspace.modulename
modulename is a string

</pre>

=end html

=begin text

$modules is a reference to a list where each element is a Workspace.modulename
modulename is a string


=end text

=item Description

List all typespec modules.

=back

=cut

sub list_modules
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 0)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function list_modules (received $n, expecting 0)");
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.list_modules",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'list_modules',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method list_modules",
					    status_line => $self->{client}->status_line,
					    method_name => 'list_modules',
				       );
    }
}



=head2 get_typespec

  $spec = $obj->get_typespec($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a Workspace.GetTypespecParams
$spec is a Workspace.typespec
GetTypespecParams is a reference to a hash where the following keys are defined:
	mod has a value which is a Workspace.modulename
	ver has a value which is a Workspace.spec_version
modulename is a string
spec_version is a string
typespec is a string

</pre>

=end html

=begin text

$params is a Workspace.GetTypespecParams
$spec is a Workspace.typespec
GetTypespecParams is a reference to a hash where the following keys are defined:
	mod has a value which is a Workspace.modulename
	ver has a value which is a Workspace.spec_version
modulename is a string
spec_version is a string
typespec is a string


=end text

=item Description

Get a typespec.

=back

=cut

sub get_typespec
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_typespec (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_typespec:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_typespec');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.get_typespec",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_typespec',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_typespec",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_typespec',
				       );
    }
}



=head2 get_jsonschema

  $schema = $obj->get_jsonschema($type)

=over 4

=item Parameter and return types

=begin html

<pre>
$type is a Workspace.type_string
$schema is a Workspace.jsonschema
type_string is a string
jsonschema is a string

</pre>

=end html

=begin text

$type is a Workspace.type_string
$schema is a Workspace.jsonschema
type_string is a string
jsonschema is a string


=end text

=item Description

Get JSON schema for a type.

=back

=cut

sub get_jsonschema
{
    my($self, @args) = @_;

# Authentication: none

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function get_jsonschema (received $n, expecting 1)");
    }
    {
	my($type) = @args;

	my @_bad_arguments;
        (!ref($type)) or push(@_bad_arguments, "Invalid type for argument 1 \"type\" (value was \"$type\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to get_jsonschema:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'get_jsonschema');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.get_jsonschema",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'get_jsonschema',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method get_jsonschema",
					    status_line => $self->{client}->status_line,
					    method_name => 'get_jsonschema',
				       );
    }
}



=head2 administer

  $response = $obj->administer($command)

=over 4

=item Parameter and return types

=begin html

<pre>
$command is an UnspecifiedObject, which can hold any non-null object
$response is an UnspecifiedObject, which can hold any non-null object

</pre>

=end html

=begin text

$command is an UnspecifiedObject, which can hold any non-null object
$response is an UnspecifiedObject, which can hold any non-null object


=end text

=item Description

The administration interface.

=back

=cut

sub administer
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function administer (received $n, expecting 1)");
    }
    {
	my($command) = @args;

	my @_bad_arguments;
        (defined $command) or push(@_bad_arguments, "Invalid type for argument 1 \"command\" (value was \"$command\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to administer:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'administer');
	}
    }

    my $result = $self->{client}->call($self->{url}, {
	method => "Workspace.administer",
	params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{code},
					       method_name => 'administer',
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method administer",
					    status_line => $self->{client}->status_line,
					    method_name => 'administer',
				       );
    }
}



sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, {
        method => "Workspace.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'administer',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method administer",
            status_line => $self->{client}->status_line,
            method_name => 'administer',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for Bio::KBase::workspace::Client\n";
    }
    if ($sMajor == 0) {
        warn "Bio::KBase::workspace::Client version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 boolean

=over 4



=item Description

A boolean. 0 = false, other = true.


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 ws_id

=over 4



=item Description

The unique, permanent numerical ID of a workspace.


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 ws_name

=over 4



=item Description

A string used as a name for a workspace.
Any string consisting of alphanumeric characters and "_" is acceptable.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 permission

=over 4



=item Description

Represents the permissions a user or users have to a workspace:

        'a' - administrator. All operations allowed.
        'w' - read/write.
        'r' - read.
        'n' - no permissions.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 username

=over 4



=item Description

Login name of a KBase user account.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 timestamp

=over 4



=item Description

A time in the format YYYY-MM-DDThh:mm:ssZ, where Z is the difference
in time to UTC in the format +/-HHMM, eg:
        2012-12-17T23:24:06-5000 (EST time)
        2013-04-03T08:56:32+0000 (UTC time)


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 type_id

=over 4



=item Description

A type id.
References a type via the format [module].[typename] where the module
is the module name of the typespec containing the type and the typename
is the name assigned by a typedef statement.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 type_ver

=over 4



=item Description

A type version.
Specifies the type version by the format [major].[minor] where 'major'
is the major (e.g. backward incompatible) version of the type as an
integer and 'minor' is the minor (e.g. backwards compatible) version
of the type as an integer.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 type_string

=over 4



=item Description

A type string.
Specifies the type and its version in a single string in the format
[module].[typename]-[major].[minor]. See type_id and type_ver.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 usermeta

=over 4



=item Description

User provided metadata about an object.
Arbitrary key-value pairs provided by the user.


=item Definition

=begin html

<pre>
a reference to a hash where the key is a string and the value is a string
</pre>

=end html

=begin text

a reference to a hash where the key is a string and the value is a string

=end text

=back



=head2 WorkspaceIdentity

=over 4



=item Description

A workspace identifier.

                Select a workspace by one, and only one, of the numerical id or name,
                        where the name can also be a KBase ID including the numerical id,
                        e.g. kb|ws.35.
                ws_id id - the numerical ID of the workspace.
                ws_name workspace - name of the workspace or the workspace ID in KBase
                        format, e.g. kb|ws.78.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
id has a value which is a Workspace.ws_id

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
id has a value which is a Workspace.ws_id


=end text

=back



=head2 workspace_metadata

=over 4



=item Description

Meta data associated with a workspace.

        ws_id id - the numerical ID of the workspace.
        ws_name workspace - name of the workspace.
        username owner - name of the user who owns (e.g. created) this workspace.
        timestamp moddate - date when the workspace was last modified.
        permission user_permission - permissions for the authenticated user of
                this workspace.
        permission globalread - whether this workspace is globally readable.


=item Definition

=begin html

<pre>
a reference to a list containing 6 items:
0: (id) a Workspace.ws_id
1: (workspace) a Workspace.ws_name
2: (owner) a Workspace.username
3: (moddate) a Workspace.timestamp
4: (user_permission) a Workspace.permission
5: (globalread) a Workspace.permission

</pre>

=end html

=begin text

a reference to a list containing 6 items:
0: (id) a Workspace.ws_id
1: (workspace) a Workspace.ws_name
2: (owner) a Workspace.username
3: (moddate) a Workspace.timestamp
4: (user_permission) a Workspace.permission
5: (globalread) a Workspace.permission


=end text

=back



=head2 obj_id

=over 4



=item Description

The unique, permanent numerical ID of an object.


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 obj_name

=over 4



=item Description

A string used as a name for an object.
Any string consisting of alphanumeric characters and the characters
        |._- is acceptable.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 obj_ver

=over 4



=item Description

An object version.
The version of the object, starting at 1.


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 obj_ref

=over 4



=item Description

A string that uniquely identifies an object in the workspace service.

        There are several ways to uniquely identify an object in one string:
        "[ws_id].[obj_id].[obj_ver]" - for example, "23.567.2" would identify
                the second version of an object with id 567 in a workspace with id
                23.
        "[ws_name]/[obj_name]/[obj_ver]" - for example,
                "MyFirstWorkspace/MyFirstObject/3" would identify the third version
                of an object called MyFirstObject in the workspace called
                MyFirstWorkspace.
        "kb|ws.[ws_id].obj.[obj_id].ver.[obj_ver]" - for example, 
                "kb|ws.23.obj.567.ver.2" would identify the same object as in the
                first example.
        In all cases, if the version number is omitted, the latest version of
        the object is assumed.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 ObjectIdentity

=over 4



=item Description

An object identifier.

Select an object by either:
        One, and only one, of the numerical id or name of the workspace,
        where the name can also be a KBase ID including the numerical id,
        e.g. kb|ws.35.
                ws_id wsid - the numerical ID of the workspace.
                ws_name workspace - name of the workspace or the workspace ID
                        in KBase format, e.g. kb|ws.78.
        AND 
        One, and only one, of the numerical id or name of the object.
                obj_id objid- the numerical ID of the object.
                obj_name name - name of the object.
        OPTIONALLY
                obj_ver ver - the version of the object.
OR an object reference string:
        obj_ref ref - an object reference string.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
wsid has a value which is a Workspace.ws_id
name has a value which is a Workspace.obj_name
objid has a value which is a Workspace.obj_id
ver has a value which is a Workspace.obj_ver
ref has a value which is a Workspace.obj_ref

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
wsid has a value which is a Workspace.ws_id
name has a value which is a Workspace.obj_name
objid has a value which is a Workspace.obj_id
ver has a value which is a Workspace.obj_ver
ref has a value which is a Workspace.obj_ref


=end text

=back



=head2 object_metadata

=over 4



=item Description

Metadata associated with an object.

        obj_id objid - the numerical id of the object.
        obj_name name - the name of the object.
        type_string type - the type of the object.
        timestamp create_date - the creation date of the object.
        obj_ver ver - the version of the object.
        username created_by - the user that created the object.
        ws_id wsid - the workspace containing the object.
        string chsum - the md5 checksum of the object.
        int size - the size of the object in bytes.


=item Definition

=begin html

<pre>
a reference to a list containing 9 items:
0: (objid) a Workspace.obj_id
1: (name) a Workspace.obj_name
2: (type) a Workspace.type_string
3: (create_date) a Workspace.timestamp
4: (version) an int
5: (created_by) a Workspace.username
6: (wsid) a Workspace.ws_id
7: (chsum) a string
8: (size) an int

</pre>

=end html

=begin text

a reference to a list containing 9 items:
0: (objid) a Workspace.obj_id
1: (name) a Workspace.obj_name
2: (type) a Workspace.type_string
3: (create_date) a Workspace.timestamp
4: (version) an int
5: (created_by) a Workspace.username
6: (wsid) a Workspace.ws_id
7: (chsum) a string
8: (size) an int


=end text

=back



=head2 object_metadata_full

=over 4



=item Description

Metadata associated with an object, including user provided metadata.

        obj_id objid - the numerical id of the object.
        obj_name name - the name of the object.
        type_string type - the type of the object.
        timestamp create_date - the creation date of the object.
        obj_ver ver - the version of the object.
        username created_by - the user that created the object.
        ws_id wsid - the workspace containing the object.
        string chsum - the md5 checksum of the object.
        int size - the size of the object in bytes.
        usermeta metadata - arbitrary user-supplied metadata about
                the object.


=item Definition

=begin html

<pre>
a reference to a list containing 10 items:
0: (objid) a Workspace.obj_id
1: (name) a Workspace.obj_name
2: (type) a Workspace.type_string
3: (create_date) a Workspace.timestamp
4: (version) an int
5: (created_by) a Workspace.username
6: (wsid) a Workspace.ws_id
7: (chsum) a string
8: (size) an int
9: (metadata) a Workspace.usermeta

</pre>

=end html

=begin text

a reference to a list containing 10 items:
0: (objid) a Workspace.obj_id
1: (name) a Workspace.obj_name
2: (type) a Workspace.type_string
3: (create_date) a Workspace.timestamp
4: (version) an int
5: (created_by) a Workspace.username
6: (wsid) a Workspace.ws_id
7: (chsum) a string
8: (size) an int
9: (metadata) a Workspace.usermeta


=end text

=back



=head2 ProvenanceAction

=over 4



=item Description

A provenance action.

        A provenance action is an action taken while transforming one data
        object to another. There may be several provenance actions taken in
        series. An action is typically running a script, running an api
        command, etc. All of the following are optional, but more information
        provided equates to better data provenance.
        
        timestamp time - the time the action was started.
        string service - the name of the service that performed this action.
        int service_ver - the version of the service that performed this action.
        string method - the method of the service that performed this action.
        list<UnspecifiedObject> method_params - the parameters of the method
                that performed this action. If the object is a workspace object,
                put the object id in the input_ws_object list and refer to it here
                by the %N syntax described below.
        string script - the name of the script that performed this action.
        int script_ver - the version of the script that performed this action.
        string script_command_line - the command line provided to the script
                that performed this action. If workspace objects were provided in
                the command line, put the object id in the input_ws_object list
                and refer to it here by the %N syntax described below.
        list<ObjectIdentifier> input_ws_objects - the workspace objects that
                were used as input to this action. Refer to these objects
                elsewhere in the action via the syntax %N, where N is the index
                of the object in this list.
        list<string> intermediate_incoming - if the previous action produced 
                output that 1) was not stored in a referrable way, and 2) is
                used as input for this action, provide it with an arbitrary and
                unique ID here, in the order of the input arguments to this action.
                These IDs can be used in the method_params argument.
        list<string> intermediate_outgoing - if this action produced output
                that 1) was not stored in a referrable way, and 2) is
                used as input for the next action, provide it with an arbitrary and
                unique ID here, in the order of the output values from this action.
                These IDs can be used in the intermediate_incoming argument in the
                next action.
        string description - a free text description of this action, limited to
                1000 characters. Longer descriptions will be silently truncated.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
time has a value which is a Workspace.timestamp
service has a value which is a string
service_ver has a value which is an int
method has a value which is a string
method_params has a value which is a reference to a list where each element is an UnspecifiedObject, which can hold any non-null object
script has a value which is a string
script_ver has a value which is an int
script_command_line has a value which is a string
description has a value which is a string
input_ws_objects has a value which is a reference to a list where each element is a Workspace.ObjectIdentity
intermediate_incoming has a value which is a reference to a list where each element is a string
intermediate_outgoing has a value which is a reference to a list where each element is a string
description has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
time has a value which is a Workspace.timestamp
service has a value which is a string
service_ver has a value which is an int
method has a value which is a string
method_params has a value which is a reference to a list where each element is an UnspecifiedObject, which can hold any non-null object
script has a value which is a string
script_ver has a value which is an int
script_command_line has a value which is a string
description has a value which is a string
input_ws_objects has a value which is a reference to a list where each element is a Workspace.ObjectIdentity
intermediate_incoming has a value which is a reference to a list where each element is a string
intermediate_outgoing has a value which is a reference to a list where each element is a string
description has a value which is a string


=end text

=back



=head2 CreateWorkspaceParams

=over 4



=item Description

Input parameters for the "create_workspace" function.

        Required arguments:
        ws_name workspace - name of the workspace to be created.
        
        Optional arguments:
        permission globalread - 'r' to set workspace globally readable,
                default 'n'.
        string description - A free-text description of the workspace, 1000
                characters max. Longer strings will be mercilessly and brutally
                truncated.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
globalread has a value which is a Workspace.permission
description has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
globalread has a value which is a Workspace.permission
description has a value which is a string


=end text

=back



=head2 SetPermissionsParams

=over 4



=item Description

Input parameters for the "set_permissions" function.

        One, and only one, of the following is required:
        ws_id id - the numerical ID of the workspace.
        ws_name workspace - name of the workspace or the workspace ID in KBase
                format, e.g. kb|ws.78.
        
        Required arguments:
        permission new_permission - the permission to assign to the users.
        list<username> users - the users whose permissions will be altered.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
id has a value which is a Workspace.ws_id
new_permission has a value which is a Workspace.permission
users has a value which is a reference to a list where each element is a Workspace.username

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
id has a value which is a Workspace.ws_id
new_permission has a value which is a Workspace.permission
users has a value which is a reference to a list where each element is a Workspace.username


=end text

=back



=head2 ObjectSaveData

=over 4



=item Description

An object and associated data required for saving.

        Required parameters:
        type_id type - the type of the object.
        UnspecifiedObject data - the object data.
        
        Optional parameters:
        One of an object name or id. If no name or id is provided the name
                will be set to the object id as a string, possibly with -\d+
                appended if that object id already exists as a name.
        obj_name name - the name of the object.
        obj_id objid - the id of the object to save over.
        usermeta metadata - arbitrary user-supplied metadata for the object,
                not to exceed 16kb.
        list<ProvenanceAction> provenance - provenance data for the object.
        type_ver tver - the version of the type. If the version or minor
                version is not provided the latest version will be assumed.
        boolean hidden - true if this object should not be listed when listing
                workspace objects.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
type has a value which is a Workspace.type_id
data has a value which is an UnspecifiedObject, which can hold any non-null object
name has a value which is a Workspace.obj_name
objid has a value which is a Workspace.obj_id
metadata has a value which is a Workspace.usermeta
provenance has a value which is a reference to a list where each element is a Workspace.ProvenanceAction
tver has a value which is a Workspace.type_ver
hidden has a value which is a Workspace.boolean

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
type has a value which is a Workspace.type_id
data has a value which is an UnspecifiedObject, which can hold any non-null object
name has a value which is a Workspace.obj_name
objid has a value which is a Workspace.obj_id
metadata has a value which is a Workspace.usermeta
provenance has a value which is a reference to a list where each element is a Workspace.ProvenanceAction
tver has a value which is a Workspace.type_ver
hidden has a value which is a Workspace.boolean


=end text

=back



=head2 SaveObjectsParams

=over 4



=item Description

Input parameters for the "save_objects" function.

        One, and only one, of the following is required:
        ws_id id - the numerical ID of the workspace.
        ws_name workspace - name of the workspace or the workspace ID in KBase
                format, e.g. kb|ws.78.
        
        Required arguments:
        list<ObjectSaveData> objects - the objects to save.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
id has a value which is a Workspace.ws_id
objects has a value which is a reference to a list where each element is a Workspace.ObjectSaveData

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
workspace has a value which is a Workspace.ws_name
id has a value which is a Workspace.ws_id
objects has a value which is a reference to a list where each element is a Workspace.ObjectSaveData


=end text

=back



=head2 ObjectData

=over 4



=item Description

The data and metadata for an object.

        UnspecifiedObject data - the object's data.
        object_metadata_full meta - metadata about the object.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
data has a value which is an UnspecifiedObject, which can hold any non-null object
meta has a value which is a Workspace.object_metadata_full

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
data has a value which is an UnspecifiedObject, which can hold any non-null object
meta has a value which is a Workspace.object_metadata_full


=end text

=back



=head2 typespec

=over 4



=item Description

A KBase Interface Definition Language (KIDL) typespec.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 modulename

=over 4



=item Description

The module name of a KIDL typespec.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 typename

=over 4



=item Description

The name of a type in a KIDL typespec module.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 spec_version

=over 4



=item Description

The version of a typespec.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 jsonschema

=over 4



=item Description

The JSON Schema for a type.


=item Definition

=begin html

<pre>
a string
</pre>

=end html

=begin text

a string

=end text

=back



=head2 CompileTypespecParams

=over 4



=item Description

Parameters for the compile_typespec function.

        Required parameters:
        One of:
        typespec spec - the new typespec to compile.
        modulename mod - the module to recompile.
        
        Optional parameters:
        boolean dryrun - Return, but do not save, the results of compiling the 
                spec. Default true. Set to false for making permanent changes.
        list<typename> new_types - types in the spec to make available in the
                workspace service. When compiling a spec for the first time, if
                this argument is empty no types will be made available. Previously
                available types remain so upon recompilation of a spec or
                compilation of a new spec.
        list<typename> remove_types - no longer make these types available in
                the workspace service for the new version of the spec. This does
                not remove versions of types previously compiled.
        mapping<modulename, spec_version> dependencies - By default, the
                latest versions of spec dependencies will be included when
                compiling a spec. Specific versions can be specified here.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
spec has a value which is a Workspace.typespec
mod has a value which is a Workspace.modulename
new_types has a value which is a reference to a list where each element is a Workspace.typename
remove_types has a value which is a reference to a list where each element is a Workspace.typename
dependencies has a value which is a reference to a hash where the key is a Workspace.modulename and the value is a Workspace.spec_version
dryrun has a value which is a Workspace.boolean

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
spec has a value which is a Workspace.typespec
mod has a value which is a Workspace.modulename
new_types has a value which is a reference to a list where each element is a Workspace.typename
remove_types has a value which is a reference to a list where each element is a Workspace.typename
dependencies has a value which is a reference to a hash where the key is a Workspace.modulename and the value is a Workspace.spec_version
dryrun has a value which is a Workspace.boolean


=end text

=back



=head2 ReleaseTypesParams

=over 4



=item Description

Parameters for the release_types function. 

        Releases the most recent version of a type or types. Releasing a
        type does two things:
        1) If the type's major version is 0, it is changed to 1. A major
                version of 0 implies that the type is in development and may have
                backwards compatible changes from minor version to minor version.
                Once a type is released, backwards incompatible changes always
                cause a major version increment.
        2) This version of the type becomes the default version, and if a 
                specific version is not supplied in a function call, this version
                will be used. This means that newer, unreleased versions of the
                type may be skipped.
        
        Required parameters:
        One of:
        modulename mod - releases all the types for this module
        type_id type - releases this type.
        
        Optional parameters:
        list<string> types - if a module is specified, specify here the types
                to release. Default is all types. If type is specified this
                argument is ignored.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
mod has a value which is a Workspace.modulename
type has a value which is a Workspace.type_id
types has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
mod has a value which is a Workspace.modulename
type has a value which is a Workspace.type_id
types has a value which is a reference to a list where each element is a string


=end text

=back



=head2 GetTypespecParams

=over 4



=item Description

Parameters for the get_typespec function.

        Required parameters:
        modulename mod - the name of the module to retrieve.
        
        Optional parameters:
        spec_version ver - the version of the module to retrieve. Defaults to
                the latest version.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
mod has a value which is a Workspace.modulename
ver has a value which is a Workspace.spec_version

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
mod has a value which is a Workspace.modulename
ver has a value which is a Workspace.spec_version


=end text

=back



=cut

package Bio::KBase::workspace::Client::RpcClient;
use base 'JSON::RPC::Client';

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $obj) = @_;
    my $result;

    if ($uri =~ /\?/) {
       $result = $self->_get($uri);
    }
    else {
        Carp::croak "not hashref." unless (ref $obj eq 'HASH');
        $result = $self->_post($uri, $obj);
    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Client'));
        }
    }
    else {
        # $obj->{id} = $self->id if (defined $self->id);
	# Assign a random number to the id if one hasn't been set
	$obj->{id} = (defined $self->id) ? $self->id : substr(rand(),2);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
