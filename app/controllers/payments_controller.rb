class PaymentsController < ApplicationController
  

  def payments_with_quality_check
    url = 'http://localhost:9292/api/bookings'
    response = HTTParty.get(url)
    payment = PaymentFormatter.new
    @payments_report = payment.format(response["bookings"])
   rescue StandardError => e
    @error = e
  end
end