require 'spec_helper'

describe 'Expose' do
  describe "handles errors" do
    
    describe "initial setup (sanity check)" do
      before(:each) do
        class User < ActiveRecord::Base
          include Expose::Model
          attr_protected :important
          attr_protected :sometimes_important
        end
      end
      subject { User.new }
    
      it { should expose(:name) }
      it { should protect(:important) }
      it { should protect(:sometimes_important) }
      it { should expose(:not_important) }
    end
  
    describe "expose with invalid name" do
      it "raises error" do
        expect { 
          class User < ActiveRecord::Base
            include Expose::Model
            attr_protected :important
            attr_protected :sometimes_important
            expose :invalid_name
          end }.to raise_error
      end
      # it "should skip over invalid name, issure warning" do
      #   subject.send(:_exposures).should_not include(:invalid_name)
      # end
    end
    
    describe "expose with double declaration" do
      before(:each) do
        class User < ActiveRecord::Base
          include Expose::Model
          attr_protected :important
          attr_protected :sometimes_important
          expose :sometimes_important, :state => 'new'
          expose :sometimes_important, :not_state => 'closed'
          expose :sometimes_important, :state => 'open'
        end
      end
      subject { User.new }
      
      it "writes over the previous definitions" do
        subject.send(:_exposures).should include(:sometimes_important)
        subject.send(:_exposures)[:sometimes_important].should include(:state)
        subject.send(:_exposures)[:sometimes_important].should_not include(:not_state)
        subject.send(:_exposures)[:sometimes_important][:state].should == 'open'
      end
    end
    
    describe "expose two classes with no interferences" do
      before(:each) do
        class User < ActiveRecord::Base
          include Expose::Model
          attr_protected :important
          attr_protected :sometimes_important
          expose :sometimes_important, :state => 'open'
        end
        class Account < ActiveRecord::Base
          include Expose::Model
          attr_protected :important
          attr_protected :sometimes_important
          expose :important, :state => 'new'
        end
      end
      
      it "keeps separate exposure lists" do
        User.send(:_exposures).should include(:sometimes_important)
        User.send(:_exposures).should_not include(:important)
        Account.send(:_exposures).should include(:important)
        Account.send(:_exposures).should_not include(:sometimes_important)
      end
    end
    
  end
end