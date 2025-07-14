class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception


  protected

 


  private
def current_user
  @current_user ||= begin
    if session[:user_id]
      User.find_by(id: session[:user_id])
    else
      u = User.new_guest
      session[:user_id] = u.id
      u
    end
  end
end
  def current_page
    if current_user != nil
      @current_page = @current_user.current_page
      return @current_page
    else
      return PAGE[:users]
    end
  end

  def current_search_query
    if (current_user != nil) then
      if SearchQuery.exists?(user_id: current_user) then
        return @current_search_query = SearchQuery.where(["user_id = ?", current_user]).last.id
      end

    end
    return @current_search_query = SearchQuery.find_by_id(DEFAULT_PAGE[:search_query])
  end



  def root_group
    @root_group = GroupName.where(["user_id = ?", current_user.id]).first
    if @root_group == nil
      @root_group = GroupName.new
      @root_group.user_id = current_user.id
      @root_group.name = "Root"
      @root_group.save
    end
    return @root_group;
  end



  def call_rake(task, options = {})
    options[:rails_env] ||= Rails.env
    args = options.map { |n, v| "#{n.to_s.upcase}='#{v}'" }
    system "rake #{task} #{args.join(' ')} --trace 2>&1 >> #{Rails.root}/log/rake.log &"
  end



  helper_method :current_user
  helper_method :current_page
  helper_method :current_search_query

  helper_method :root_group

  def authorize
    redirect_to login_url, alert: "Not authorized" if current_user.nil?
  end

end
