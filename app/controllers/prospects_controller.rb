class ProspectsController < ApplicationController
  def create
    @prospect = Prospect.new(email: params[:email])
    @prospect.save
    render text: "Awesome to have you on board! We'll let you know when we launch, which will happen really soon!"
  end
end