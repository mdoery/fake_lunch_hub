require 'rails_helper'

RSpec.describe Group, type: :model do
#  pending "add some examples to (or delete) #{__FILE__}"
  before do
    @group = Group.new(name: "Ben Franklin Labs")
  end
 
  subject { @group }
 
  describe "when name is not present" do
    before { @group.name = " " }
    it { should_not be_valid }
  end
end
