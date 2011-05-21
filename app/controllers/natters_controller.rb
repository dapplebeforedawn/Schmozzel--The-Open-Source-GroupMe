class NattersController < ApplicationController
  skip_before_filter :verify_authenticity_token, only:[:natters_mobile]

  def index
    @natters = Natter.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @natters }
    end
  end

  def show
    @natter = Natter.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @natter }
    end
  end

  def new
    @natter = Natter.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @natter }
    end
  end

  def edit
    @natter = Natter.find(params[:id])
  end

  def create
    @natter = Natter.new(params[:natter])

    respond_to do |format|
      if @natter.save
        format.html { redirect_to(@natter, :notice => 'Natter was successfully created.') }
        format.xml  { render :xml => @natter, :status => :created, :location => @natter }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @natter.errors, :status => :unprocessable_entity }
      end
    end
  end

  def mobile
    @schmozzeler = Schmozzeler.find_or_create_by_address clean_field(params[:from])
    if command_natter params[:text]
      render text:"OK" and return 
    end
    @natter = Natter.new(message:params[:text], schmozzeler_id:@schmozzeler.id)
    if @natter.save
      mail = Postoffice.natter(Schmozzeler.all.map(&:address)-[@schmozzeler.address], @natter.message, @schmozzeler)
      mail.deliver
      render text:"OK"
    else
      mail = Postoffice.natter(@schmozzeler.address)
      mail.deliver
      render text:"NG", :status=>:unprocessable_entity
    end
  end

  def clean_field dirty
    dirty.gsub /\n/, '' unless dirty.nil?
  end

  def command_natter text
    is_command = !(text =~ /^#([^\s]+)/).nil?
    if is_command
      command_value = text.gsub /^##{$1}\s/, ''
      case $1
        when 'call_me' then @schmozzeler.rename command_value; comand_result = "Hello, #{command_value}"
        when 'list' then command_result = 'call_me - to name yourself\n'
        else command_result = 'Sorry, I don\'t know how to do that.  Try, #list'
      end
      mail = Postoffice.natter @schmozzeler.address, command_result
      mail.deliver
    end
    return is_command
  end

  def update
    @natter = Natter.find(params[:id])

    respond_to do |format|
      if @natter.update_attributes(params[:natter])
        format.html { redirect_to(@natter, :notice => 'Natter was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @natter.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @natter = Natter.find(params[:id])
    @natter.destroy

    respond_to do |format|
      format.html { redirect_to(natters_url) }
      format.xml  { head :ok }
    end
  end
end
