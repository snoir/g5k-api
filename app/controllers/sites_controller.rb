# Copyright (c) 2009-2011 Cyril Rohr, INRIA Rennes - Bretagne Atlantique
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'resources_controller'

class SitesController < ResourcesController

  def status
    # fetch valid clusters
    enrich_params(params)

    params[:job_details]='no' if is_anonymous?
    params[:waiting]='no' if is_anonymous?

    site_clusters=lookup_path("/sites/#{params[:id]}/clusters", params)
    valid_clusters = site_clusters['items'].map{|i| i['uid']}
    Rails.logger.info "Valid clusters=#{valid_clusters.inspect}"

    result = {
      "uid" => Time.now.to_i,
      "nodes" => OAR::Resource.status(:clusters => valid_clusters, :network_address => params[:network_address], :job_details => params[:job_details], :waiting => params[:waiting]),
      "links" => [
        {
          "rel" => "self",
          "href" => uri_to(status_site_path(params[:id])),
          "type" => media_type(:g5kitemjson)
        },
        {
          "rel" => "parent",
          "href" => uri_to(site_path(params[:id])),
          "type" => media_type(:g5kitemjson)
        }
      ]
    }
    result["disks"] = OAR::Resource.disk_status(:clusters => valid_clusters, :network_address => params[:network_address], :job_details => params[:job_details], :waiting => params[:waiting]) if params[:disks] != "no"
    
    respond_to do |format|
      format.g5kitemjson { render :json => result }
      format.json { render :json => result }
    end
  end
  
  protected
  
  def collection_path
    sites_path
  end
  
  def links_for_item(item)
    links = super(item)
    %w{jobs deployments vlans metrics}.each do |rel|
      links.push({
        "rel" => rel,
        "type" => media_type(:g5kcollectionjson),
        "href" => uri_to(File.join(resource_path(item["uid"]), rel))
      })
    end
    links.push({
      "rel" => "status",
      "type" => media_type(:g5kitemjson),
      "href" => uri_to(File.join(resource_path(item["uid"]), "status"))
    })
    links
  end

end
