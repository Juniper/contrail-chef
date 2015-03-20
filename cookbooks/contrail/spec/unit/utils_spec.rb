# encoding: UTF-8
require 'spec_helper'
require ::File.join ::File.dirname(__FILE__), '..', '..', 'libraries', 'utils'

describe 'contrail::default' do

  describe 'Contrail Search' do
    let(:runner) { ChefSpec::Runner.new }
    let(:chef_run) do
      node.set['contrail']['openstack_controller_role'] = 'os-controller-role'
      runner.converge(described_recipe)
    end
    let(:node) { runner.node }
    let(:subject) { Object.new.extend(Contrail) }

    describe '#search_for' do
      it 'returns the correct result' do
        search_results = [
          { 'hostname' => 'dummynode' }
        ]
        expect(subject).to receive(:node).and_return(chef_run.node)
        expect(subject).to receive(:search)
          .with(:node, 'roles:dummy-role AND chef_environment:_default')
          .and_return(search_results)
        resp = subject.search_for('dummy-role')
        expect(resp.length).to eq (1)
        expect(resp[0]['hostname']).to eq ('dummynode')
      end

      it 'always returns an empty list' do
        expect(subject).to receive(:node).and_return(chef_run.node)
        expect(subject).to receive(:search)
          .with(:node, 'roles:simple-role AND chef_environment:_default')
          .and_return(nil)
        resp = subject.search_for('simple-role')
        expect(resp).to eq ([])
      end
    end

    describe '#openstack_controller_node_ip' do
      it 'returns the correct IP address' do
        search_results = [
          { 'ipaddress' => '1.2.3.4' }
        ]
        expect(subject).to receive(:node).exactly(3).and_return(chef_run.node)
        expect(subject).to receive(:search)
          .with(:node, 'roles:os-controller-role AND chef_environment:_default')
          .and_return(search_results)
        resp = subject.get_openstack_controller_node_ip
        expect(resp).to eq '1.2.3.4'
      end

      it 'raises an error when there are not OpenStack controller nodes' do
        expect(subject).to receive(:node).exactly(2).and_return(chef_run.node)
        expect(subject).to receive(:search)
          .with(:node, 'roles:os-controller-role AND chef_environment:_default')
          .and_return([])
        expect { subject.get_openstack_controller_node_ip }.to raise_error
      end

    end

  end

end
