# encoding: UTF-8
require 'spec_helper'
require ::File.join ::File.dirname(__FILE__), '..', '..', 'libraries', 'utils'

describe 'contrail::default' do

  describe 'Contrail Search' do
    let(:runner) { ChefSpec::Runner.new }
    let(:chef_run) { runner.converge(described_recipe) }
    let(:subject) { Object.new.extend(Contrail) }
    let(:node) { runner.node }

    before do
      allow(subject).to receive(:node).and_return(chef_run.node)
    end

    describe '#search_for' do
      it 'returns the correct result' do
        search_results = [
          { 'hostname' => 'dummynode' }
        ]
        expect(subject).to receive(:search)
          .with(:node, 'roles:dummy-role AND chef_environment:_default')
          .and_return(search_results)
        resp = subject.search_for('dummy-role')
        expect(resp.length).to eq (1)
        expect(resp[0]['hostname']).to eq ('dummynode')
      end

      it 'always returns an empty list' do
        expect(subject).to receive(:search)
          .with(:node, 'roles:simple-role AND chef_environment:_default')
          .and_return(nil)
        resp = subject.search_for('simple-role')
        expect(resp).to eq ([])
      end
    end

    describe '#get_openstack_controller_node_ip' do
      it 'returns the correct IP address' do
        search_results = [
          { 'ipaddress' => '1.2.3.4' }
        ]
        expect(subject).to receive(:search)
          .with(:node, 'roles:contrail-openstack AND chef_environment:_default')
          .and_return(search_results)
        resp = subject.get_openstack_controller_node_ip
        expect(resp).to eq '1.2.3.4'
      end

      it 'raises an error when there are no OpenStack controller nodes' do
        expect(subject).to receive(:search)
          .with(:node, 'roles:contrail-openstack AND chef_environment:_default')
          .and_return([])
        expect { subject.get_openstack_controller_node_ip }.to raise_error
      end
    end

    describe '#get_contrail_controller_node_ip' do
      it 'returns the correct IP address' do
        expect(subject).to receive(:search)
          .with(:node, 'roles:contrail-control AND chef_environment:_default')
          .and_return([ {'ipaddress' => '5.6.7.8'} ])
        resp = subject.get_contrail_controller_node_ip
        expect(resp).to eq '5.6.7.8'
      end

      it 'raises an error when there are no Contrail controller nodes' do
        expect(subject).to receive(:search)
          .with(:node, 'roles:contrail-control AND chef_environment:_default')
          .and_return([])
        expect { subject.get_contrail_controller_node_ip }.to raise_error
      end
    end

  end

end
