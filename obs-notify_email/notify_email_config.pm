#
# Copyright (c) 2014 Christian Schneemann, B1 Systems GmbH
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program (see the file COPYING); if not, write to the
# Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
#
################################################################
#
# Module send emails
#

package notify_email_config;

use strict;
use warnings;

our $curl_binary = "/usr/bin/curl -f -k";

# url to OBS API
our $api_url = "https://localhost:444";

# user for API
our $api_user = "";

# password for API user
our $api_pass = "";

# attribute for notification settings
our $notify_attr = "B1:notify";

# which roles should be notified? regex syntax allowed here
our $notified_roles = "maintainer|bugowner";

# remember to escape @ => \@
our $from_mail = "root\@localhost";

# custom mail relay (optional)
our $smtp_server = undef;

1;
