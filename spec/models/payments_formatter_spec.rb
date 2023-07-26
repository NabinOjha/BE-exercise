require "rails_helper"

RSpec.describe PaymentFormatter, type: :model do 
  let(:formatter) { described_class.new(payment) }

  describe "#format" do 
  end

  describe "#amount_with_fees" do
    let(:payment)  { {"reference":"1","amount": amount,"amount_received": 20, "country_from":"USA","sender_full_name":"Sams","sender_address":"2166 Efrain Pine","school":"MIT","currency_from": "USD","student_id": 1,"email":"sam@gmail.com"}}
    
    context "when the amount is less than 1000" do
      let(:amount)  { 10 }
      it "returns amount with 5% fee" do 
        expect(formatter.send(:amount_with_fees)).to  eq 10.5  # amount 10 + 5% of 10
      end
    end

    context "when the amount is in between than 1000 and 10000" do
      let(:amount)  { 1500 }
      it "returns amount with 3% fee" do 
        expect(formatter.send(:amount_with_fees)).to  eq 1545
      end
    end

    context "when the amount is greater than 10000" do 
      let(:amount)  { 15000 }
      it "returns amount with 2% fee" do 
        expect(formatter.send(:amount_with_fees)).to  eq 15300
      end
    end
    
  end

  describe "#set_amount_received_to_usd" do
    let(:payment)  { {"reference":"1","amount": 15000, "amount_received": 20000, "country_from":"USA","sender_full_name":"Sams","sender_address":"2166 Efrain Pine","school":"MIT","currency_from": currency_from,"student_id": 1,"email":"sam@gmail.com"}}

    context "when the currency is usd" do 
      let(:currency_from)  { "USD" }

      it "returns the same amount" do 
        expect(formatter.send(:set_amount_received_to_usd)).to eq payment[:amount_received]  
      end

    end

    context "when the currency is CAD" do
      let(:currency_from)  { "CAD" }

      it "returns the converted amount" do 
        expect(formatter.send(:set_amount_received_to_usd)).to eq payment[:amount_received]  * 0.76
      end

    end

    context "when the currency is EUR" do 
      let(:currency_from)  { "EUR" }

      it "returns the converted amount" do 
        expect(formatter.send(:set_amount_received_to_usd)).to eq payment[:amount_received]  * 1.11
      end
    end

  end

  describe "#get_quality_of_payment" do 
    context "when invalid email" do     
      let(:payment)  { {"email":"some_invalid_email"}}
      
      it "return InvalidEmail" do 
        expect(formatter.send(:get_quality_of_payment)).to  eq "InvalidEmail"
      end
    end

    context "when duplicate payment" do
      let(:payment)  { {student_id: 1}}
      let(:payment_2)  { {student_id: 1}}

      it "returns DuplicatePayment" do 
        expect(formatter.send(:get_quality_of_payment)).to  eq "DuplicatePayment"
      end
    end

    context "when amount greater then threshold" do
      let(:payment) { { amount: 1000001 } }

      it "returns AmountThreshold" do ]
        expect(formatter.send(:get_quality_of_payment)).to  eq "AmountThreshold"
      end
      
    end
    
    
    
  end


  
end