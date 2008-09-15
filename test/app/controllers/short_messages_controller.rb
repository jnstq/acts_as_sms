class ShortMessagesController < ApplicationController
  
  def index
    @short_messages = ShortMessage.all
  end

  def new
    @short_message = ShortMessage.new
  end
  
  def create
    @short_message = ShortMessage.new(params[:short_message])
    
    respond_to do |format|
      if @short_message.save
        flash[:notice] = 'ShortMessage was successfully sent.'
        format.html { redirect_to(:action => 'index') }
        format.xml { render :xml => @short_message, :status => :created, :location => @short_message }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @short_message.errors, :status => :unprocessable_entity }
      end
    end
  end
  
end
