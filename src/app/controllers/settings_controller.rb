#
# Copyright (C) 2009 Red Hat, Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA  02110-1301, USA.  A copy of the GNU General Public License is
# also available at http://www.gnu.org/copyleft/gpl.html.

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class SettingsController < ApplicationController
  before_filter :require_user

  # Settings MetaData Keys
  SELF_SERVICE_DEFAULT_QUOTA = "self_service_default_quota"
  KEYS = [SELF_SERVICE_DEFAULT_QUOTA]

  def section_id
    "system_settings"
  end

  def index
    @providers = Provider.list_for_user(@current_user, Privilege::VIEW)
  end

 def self_service
   require_privilege(Privilege::MODIFY)
   @self_service_default_quota = MetadataObject.lookup(SELF_SERVICE_DEFAULT_QUOTA)
 end

 def general_settings
   require_privilege(Privilege::MODIFY)
 end

 def update
   KEYS.each do |key|
     if params[key]
       if key == SELF_SERVICE_DEFAULT_QUOTA
         @self_service_default_quota = MetadataObject.lookup(key)
         if !@self_service_default_quota.update_attributes(params[key])
           flash[:notice] = "Could not update the default quota"
           render :self_service
           return
         end
       elsif key == SELF_SERVICE_DEFAULT_POOL
         if Pool.exists?(params[key])
           MetadataObject.set(key, Pool.find(params[key]))
         end
       elsif key == SELF_SERVICE_DEFAULT_ROLE
         if Role.exists?(params[key])
           MetadataObject.set(key, Role.find(params[key]))
         end
       else
         MetadataObject.set(key, params[key])
       end
     end
   end
   flash[:notice] = "Settings Updated!"
   redirect_to :action => 'self_service'
 end

end
