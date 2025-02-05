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

require 'spec_helper'

describe RootController do
  render_views

  it 'should return the API index' do
    get :show, params: { id: 'grid5000', format: :json }
    expect(response.status).to eq(200)
    expect(json).to eq({
                         'type' => 'grid',
                         'uid' => 'grid5000',
                         'version' => @latest_commit,
                         'timestamp' => @now.to_i,
                         'links' => [
                           { 'rel' => 'network_equipments', 'href' => '/network_equipments', 'type' => 'application/vnd.grid5000.collection+json' },
                           { 'rel' => 'sites', 'href' => '/sites', 'type' => 'application/vnd.grid5000.collection+json' },
                           { 'rel' => 'self', 'type' => 'application/vnd.grid5000.item+json', 'href' => '/' },
                           { 'rel' => 'parent', 'type' => 'application/vnd.grid5000.item+json', 'href' => '/' },
                           { 'rel' => 'version', 'type' => 'application/vnd.grid5000.item+json', 'href' => "/versions/#{@latest_commit}" },
                           { 'rel' => 'versions', 'type' => 'application/vnd.grid5000.collection+json', 'href' => '/versions' },
                           { 'rel' => 'users', 'type' => 'application/vnd.grid5000.collection+json', 'href' => '/users' }
                         ]
                       })
  end

  it 'should correcly add the version if any' do
    @request.env['HTTP_X_API_VERSION'] = 'sid'
    get :show, params: { id: 'grid5000', format: :json }
    expect(response.status).to eq(200)
    expect(json).to eq({
                         'type' => 'grid',
                         'uid' => 'grid5000',
                         'version' => @latest_commit,
                         'timestamp' => @now.to_i,
                         'links' => [
                           { 'rel' => 'network_equipments', 'href' => '/sid/network_equipments', 'type' => 'application/vnd.grid5000.collection+json' },
                           { 'rel' => 'sites', 'href' => '/sid/sites', 'type' => 'application/vnd.grid5000.collection+json' },
                           { 'rel' => 'self', 'type' => 'application/vnd.grid5000.item+json', 'href' => '/sid/' },
                           { 'rel' => 'parent', 'type' => 'application/vnd.grid5000.item+json', 'href' => '/sid/' },
                           { 'rel' => 'version', 'type' => 'application/vnd.grid5000.item+json', 'href' => "/sid/versions/#{@latest_commit}" },
                           { 'rel' => 'versions', 'type' => 'application/vnd.grid5000.collection+json', 'href' => '/sid/versions' },
                           { 'rel' => 'users', 'type' => 'application/vnd.grid5000.collection+json', 'href' => '/sid/users' }
                         ]
                       })
  end

  it "should get the correct deep view" do
    get :show, params: { id: 'grid5000', format: :json, deep: true }
    expect(response.status).to eq 200
    expect(json['total']).to eq 4
    expect(json['items'].length).to eq 4
    expect(json['items']['sites']).to be_a(Hash)
  end
end
