class IncomingShortMessagesController < ApplicationController
  
  def incoming    
    IncomingShortMessage.incoming!(params)
    head :ok
  end
  
end