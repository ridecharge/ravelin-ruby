require 'spec_helper'

describe Ravelin::PaymentMethod do
  describe "initialize" do
    describe "hash billing address" do
    it "should not include symbolized billing_address to superclass initializer" do
      allow(Ravelin::Location).to receive(:new).and_return({})
      allow(Ravelin).to receive(:convert_ids_to_strings).with(:payment_method_id, anything).and_return(1)
      expect(Ravelin).not_to receive(:convert_ids_to_strings).with(:billing_address, anything)
      described_class.new(:payment_method_id => 1, :billing_address => {:street1 => "123 Main st", :region => "NY", :city => "Manhattan", :postal_code => "10958"})
    end
    
    it "should not include string billing_address to superclass initializer" do
      allow(Ravelin::Location).to receive(:new).and_return({})
      allow(Ravelin).to receive(:convert_ids_to_strings).with(:payment_method_id, anything).and_return(1)
      expect(Ravelin).not_to receive(:convert_ids_to_strings).with("billing_address", anything)
      described_class.new(:payment_method_id => 1, "billing_address" => {:street1 => "123 Main st", :region => "NY", :city => "Manhattan", :postal_code => "10958"})
    end
    
    it "should set the billing address accessor" do
      pm = described_class.new(:payment_method_id => 1, :billing_address => {:street1 => "123 Main st", :region => "NY", :city => "Manhattan", :postal_code => "10958"})
      expect(pm.billing_address).to be_an_instance_of(Ravelin::Location)
    end
    
    it "should not attempt to set accessor if no billing address passed" do
      expect_any_instance_of(described_class).to receive(:billing_address).never
      described_class.new(:payment_method_id => 1)
    end
    end
    describe "Location billing address" do
      it "should set the billing address accessor" do
        loc = Ravelin::Location.new({:street1 => "123 Main st", :region => "NY", :city => "Manhattan", :postal_code => "10958"})
        pm = described_class.new(:payment_method_id => 1, :billing_address => loc)
        expect(pm.billing_address).to be_an_instance_of(Ravelin::Location)
        expect(pm.billing_address).to eq(loc)
      end
    end
  end
end
