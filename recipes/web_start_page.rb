#
# Cookbook Name:: usermanagement
# Recipe:: web_start_page
#
# Copyright 2011 Junta de Andalucía
#
# Authors::
#  * David Amian <damian@emergya.com>
#  * Juanje Ojeda <jojeda@emergya.com>
#
# Based on the David Amian's homepage recipe
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

update_users_config

node['userdata'].each do |userdata|
  username = userdata["name"]
  homedir = userdata["home"]
  homepage = userdata["web_start_page"]["web_start_page"]
  unless homepage.empty?
    users_prefs = []
    profiles = "#{homedir}/.mozilla/firefox/profiles.ini" 
    if File.exist? profiles
      File.open(profiles, "r") do |infile|
        while (line = infile.gets)
          aline=line.split('=')
          if aline[0] == 'Path'
            users_prefs << "#{homedir}/.mozilla/firefox/#{aline[1].chomp}/prefs.js"
          end
        end
      end
    
      users_prefs.each do |user_prefs|
        if open(user_prefs).grep(/user_pref\(\"browser.startup.homepage\"/).empty?   
          usermanagement_plain_file user_prefs do
            new_line     "user_pref(\"browser.startup.homepage\", \"#{homepage}\");"
            action :append
          end
        else
          usermanagement_plain_file user_prefs do
            before    /user_pref\(\s*\"browser.startup.homepage\".*/
            after     "user_pref(\"browser.startup.homepage\", \"#{homepage}\");"
            action :replace
          end

        end

      end
    end  
  end
end
