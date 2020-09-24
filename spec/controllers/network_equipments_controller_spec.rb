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

describe NetworkEquipmentsController do
  render_views

  describe 'GET /network_equipments' do
    it 'should get 200 in default' do
      get :index, params: { format: :json }
      expect(response.status).to eq(200)
    end

    it 'should get collection' do
      get :index, params: { format: :json }
      expect(response.status).to eq(200)
      expect(json['total']).to eq(9)
      expect(json['items'].length).to eq(9)
    end

    it 'should get collection for a site' do
      get :index, params: { site_id: 'lille', format: :json }
      expect(response.status).to eq(200)
      expect(json['total']).to eq(3)
      expect(json['items'].length).to eq(3)
    end
  end # describe "GET /network_equipments"
end
