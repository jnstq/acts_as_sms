class <%=short_message_model_name.pluralize%>Controller < ApplicationController
  
  def index
    @<%=short_message_model_name.underscore.pluralize%> = ShortMessage.all
  end

  def new
    @<%=short_message_model_name.underscore%> = ShortMessage.new
  end
  
  def create
    @<%=short_message_model_name.underscore%> = ShortMessage.new(params[:short_message])
    
    respond_to do |format|
      if @<%=short_message_model_name.underscore%>.send_message
        flash[:notice] = '<%=short_message_model_name%> was successfully sent.'
        format.html { redirect_to(:action => 'index') }
        format.xml { render :xml => @<%=short_message_model_name.underscore%>, :status => :created, :location => @<%=short_message_model_name.underscore%> }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @<%=short_message_model_name.underscore%>.errors, :status => :unprocessable_entity }
      end
    end
  end
  
end
