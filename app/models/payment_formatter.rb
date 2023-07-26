class PaymentFormatter 
  attr_accessor :payments
  
  # assumes the amount is always in USD but amount_received may vary - can change this if requirement is different
  # conversion_rates -> not the best way but works for prototyping 
  CONVERSION_RATES = { USD: 1,  CAD: 0.76, EUR: 1.11 }.freeze
  THRESHOLD_AMOUNT = 1000000

  def initialize(payment = nil)
    @current_payment = payment
  end

  def format(payments)
    payments.map do |payment| 
      @current_payment = payment.with_indifferent_access
      @current_payment[:amount] = @current_payment[:amount] || 0
      set_amount_received_to_usd
      formatted_payment = {}
      attrs.each do |attr_key| 
        attr_value = get_attr_value(attr_key)
        formatted_payment[attr_key] = attr_value
      end
      formatted_payment
    end
  end


  def get_attr_value(attr_key)
    case attr_key
    when "amountWithFees" 
      attr_value = amount_with_fees
    when "qualityCheck" 
      attr_value = get_quality_of_payment
    when "overPayment"
      attr_value = over_payment?
    when "underPayment"
      attr_value = under_payment?
    when "amountReceived"
      attr_value = @current_payment[:amount_received]
    else 
      attr_value = @current_payment[attr_key]
    end
    attr_value
  end

 

  private 

    def amount_with_fees 
      @current_payment[:amount]  + fees
    end

    def set_amount_received_to_usd
      return @current_payment[:amount_received] * CONVERSION_RATES[@current_payment[:currency_from]&.upcase&.to_sym]
    end

    def get_quality_of_payment
      quality = ''
      quality += "InvalidEmail" unless valid_email?
      quality += "DuplicatedPayment" if is_duplicate?
      quality += "AmountThreshold" if (@current_payment[:amount] + fees) > THRESHOLD_AMOUNT
    end

    def over_payment? 
      @current_payment[:amount_received] > @current_payment[:amount] + fees
    end

    def under_payment? 
      @current_payment[:amount_received] < @current_payment[:amount] + fees
    end

    def fees
      amount = @current_payment[:amount]
      return (5/100.0) * amount.to_f if amount <= 1000
      return (3/100.0) * amount.to_f if amount > 1000 && amount <= 10000
      (2/100.0) * amount.to_f if amount > 10000
    end

    def valid_email? 
      email = @current_payment[:email]
      !email.nil? && email.match?(URI::MailTo::EMAIL_REGEXP)
    end

    def is_duplicate?
      !!payments.find { |payment| payment[:student_id] == @current_payment[:student_id] }
    end

    def attrs 
      %w[reference amount amountWithFees amountReceived qualityCheck overPayment underPayment]
    end
end