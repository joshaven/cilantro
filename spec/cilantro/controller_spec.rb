require File.expand_path File.join(File.dirname(__FILE__), '..', 'spec_helper')

class Sample < Application
  namespace '/'

  get :home do
    view :index
  end

  # Main page
  get 'new_index' do
    view :index
  end

  # This is not yet limited to just one controller or namespace.
  error do
    Cilantro.report_error(env['sinatra.error'])
    view :default_error_page
  end
end

describe 'Cilantro::Controller' do
  it 'should be defined' do
    defined?(Cilantro::Controller).should be_true
  end
  
  it 'should be linked to the Cilantro Application' do
    Sample.instance_variable_get('@application').should == Cilantro.app
  end
  
  it 'should receive :namespace its aliases: (:scope & :path)'
  describe :routes do
    it 'should write routes for get'
    it 'should write routes for put'
    it 'should write routes for post'
    it 'should write routes for delete'
    it 'should write routes for head'
  end
  
  it 'should work with helper_method'
  
  it 'should allow a defination for error handeling: :error'
  
  it 'should :setup'
  it 'should :before'
  it 'should :helper'
  it 'should :'
  
end