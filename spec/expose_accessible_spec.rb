require 'spec_helper'

describe 'Expose' do
  
  describe "using attr_accessible strategy" do
    describe "initial setup" do
      before(:each) do
        class User < ActiveRecord::Base
          attr_accessible :name
          attr_accessible :not_important
        end
        User.send(:_exposures=, {})
      end
      subject { User.new }
    
      it { should expose(:name) }
      it { should protect(:important) }
      it { should protect(:sometimes_important) }
      it { should expose(:not_important) }
    end
    
    describe "expose with no options" do
      before(:each) do
        class User < ActiveRecord::Base
          attr_accessible :name
          attr_accessible :not_important
          expose :sometimes_important
        end
      end
      subject { User.new }
    
      it { should expose(:name) }
      it { should protect(:important) }
      it { should expose(:sometimes_important) }
      it { should expose(:not_important) }
    end
    
    describe "expose with :if" do
      before(:each) do
        class User < ActiveRecord::Base
          attr_accessible :name
          attr_accessible :not_important
          expose :sometimes_important, :if => Proc.new { |user| user.name == 'example name' }
        end
      end
      subject { User.new }
    
      it { should expose(:name) }
      it { should protect(:important) }
      it { should expose(:not_important) }
    
      context "when :if is true" do
        subject { User.new(:name => 'example name') }
        it { should expose(:sometimes_important) }
      end
    
      context "when :if is false" do
        subject { User.new(:name => 'name') }
        it { should protect(:sometimes_important) }
      end
    end
    
    describe "expose with :unless" do
      before(:each) do
        class User < ActiveRecord::Base
          attr_accessible :name
          attr_accessible :not_important
          expose :sometimes_important, :unless => Proc.new { |user| user.name == 'example name' }
        end
      end
      subject { User.new }
    
      it { should expose(:name) }
      it { should protect(:important) }
      it { should expose(:not_important) }
    
      context "when :unless is true" do
        subject { User.new(:name => 'example name') }
        it { should protect(:sometimes_important) }
      end
    
      context "when :unless is false" do
        subject { User.new(:name => 'name') }
        it { should expose(:sometimes_important) }
      end
    end

    describe "expose with :state" do
      before(:each) do
        class User < ActiveRecord::Base
          attr_accessible :state
          attr_accessible :name
          attr_accessible :not_important
          expose :sometimes_important, :state => 'open'
        end
      end
      subject { User.new }
  
      it { should expose(:name) }
      it { should protect(:important) }
      it { should expose(:not_important) }
    
      context "when :state matches" do
        subject { User.new(:state => 'open') }
        it { should expose(:sometimes_important) }
      end
    
      context "when :state doesn't match" do
        subject { User.new(:state => 'closed') }
        it { should protect(:sometimes_important) }
      end
    end

    describe "expose with :not_state" do
      before(:each) do
        class User < ActiveRecord::Base
          attr_accessible :state
          attr_accessible :name
          attr_accessible :not_important
          expose :sometimes_important, :not_state => 'closed'
        end
      end
      subject { User.new }
    
      it { should expose(:name) }
      it { should protect(:important) }
      it { should expose(:not_important) }
    
      context "when :not_state doesn't match" do
        subject { User.new(:state => 'open') }
        it { should expose(:sometimes_important) }
      end
    
      context "when :state matches" do
        subject { User.new(:state => 'closed') }
        it { should protect(:sometimes_important) }
      end
    end
    
    describe "allow multiple attributes in a single definition" do
      before(:each) do
        class User < ActiveRecord::Base
          attr_accessible :state
          attr_accessible :name
          attr_accessible :not_important
          expose :important, :sometimes_important, :if => Proc.new { |user| user.name == 'example name' }
        end
      end
      subject { User.new }
    
      it { should expose(:name) }
      it { should expose(:not_important) }
    
      context "when :if is true" do
        subject { User.new(:name => 'example name') }
        it { should expose(:important) }
        it { should expose(:sometimes_important) }
      end
    
      context "when :if is false" do
        subject { User.new(:name => 'name') }
        it { should protect(:important) }
        it { should protect(:sometimes_important) }
      end
    end
    
  end
end