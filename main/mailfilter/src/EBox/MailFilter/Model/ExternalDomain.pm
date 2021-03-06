# Copyright (C) 2008-2013 Zentyal S.L.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 2, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
use strict;
use warnings;

package EBox::MailFilter::Model::ExternalDomain;

use base 'EBox::Model::DataTable';

# Class:
#
#    EBox::MailFilter::Model::ExternalDomain
#
#
#    It subclasses <EBox::Model::DataTable>
#

use EBox;
use EBox::Exceptions::Internal;
use EBox::Exceptions::External;
use EBox::Gettext;
use EBox::Types::Boolean;
use EBox::Types::DomainName;
use EBox::MailVDomainsLdap;

# Group: Public methods

# Constructor: new
#
#       Create the new  model
#
# Overrides:
#
#       <EBox::Model::DataTable::new>
#
sub new
{
    my $class = shift;

    my $self = $class->SUPER::new(@_);

    bless $self, $class;
    return $self;
}

# Group: Protected methods

# Method: _table
#
#       The table description
#
sub _table
{
  my @tableHeader =
   (
     new EBox::Types::DomainName(
                             fieldName     => 'domain',
                             printableName => __('External mail domain'),
                             unique        => 1,
                             editable      => 1,
                            ),
     new EBox::Types::Boolean(
                                    fieldName     => 'allow',
                                    printableName => __('Allow connection'),
                                    editable      => 1,
                                   ),
    );

  my $dataTable =
    {
     tableName          => __PACKAGE__->nameFromClass,
     printableTableName => __(q{External mail domains}),
     modelDomain        => 'Mail',
     'defaultController' => '/MailFilter/Controller/ExternalDomain',
     'defaultActions' => [
                          'add', 'del',
                          'editField',
                          'changeView'
                         ],
     tableDescription   => \@tableHeader,
     class              => 'dataTable',
     order              => 0,
     rowUnique          => 1,
     printableRowName   => __("external mail domain"),
     help               => __("Here you can specify which external mail domains can connect to the mail filter"),
    };

}

sub validateTypedRow
{
  my ($self, $action, $params_r, $actual_r) = @_;
  if (not exists $params_r->{domain}) {
      return;
  }

  my $domain = $params_r->{domain}->value();
  my $mailVDomains = EBox::MailVDomainsLdap->new();

  if ($mailVDomains->vdomainExists($domain)) {
      throw EBox::Exceptions::External(
            __x(q|{d} is a internal Zentyal virtual main domain|,
                d => $domain
               )
                                      );
  }

}

# Method: allowed
#
# Returns:
#   - reference to a list of external mail domains for which connection is allowed
#
sub allowed
{
    my ($self) = @_;
    my @allowed;
    for my $id (@{$self->ids()}) {
        my $row = $self->row($id);
        if ($row->valueByName('allow')) {
            push (@allowed, $row->valueByName('domain'));
        }
    }
    return \@allowed;
}

1;

