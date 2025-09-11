class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])
    guest_user = current_user
    logger.info "Session creation"
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      if params[:remember_me]
        session.options[:expire_after] = 4.weeks
      end
      previous_user_ranges = CrawlerRange.where("user_id = ?", user.id)
      if previous_user_ranges.length > 0
        previous_user_ranges.destroy_all
      end
      sql_update = "UPDATE crawler_ranges SET user_id = #{user.id} WHERE user_id = #{guest_user.id}"
      ActiveRecord::Base.connection.execute(sql_update)
      previous_display_nodes = DisplayNode.where("user_id = ?", user.id)
      if previous_display_nodes.length > 0
        previous_display_nodes.destroy_all
      end
      sql_update = "UPDATE display_nodes SET user_id = #{user.id} WHERE user_id = #{guest_user.id}"
      ActiveRecord::Base.connection.execute(sql_update)

      user_queries = SearchQuery.where(user_id: user.id)
      if user_queries.length >0
        view_priority_offset = user_queries.maximum("view_priority")
      else
        view_priority_offset= 0
      end
      guest_queries = SearchQuery.where(user_id: guest_user.id)
      guest_queries.each do |gq|
        gq.user_id = user.id
        gq.view_priority = gq.view_priority+view_priority_offset
        gq.save
      end
      SearchQuery.tidy_up(user.id)
      guest_user.destroy







      logger.info "session redirect to domain_crawlers"
      session[:just_logged_in] = true
      redirect_to domain_crawlers_url
    else
      flash[:alert] = "Either the username or password was incorrect"
      redirect_to login_path
    end
  end

  def destroy
    reset_session
    logger.info "session destroyed"
    redirect_to root_path
  end
end
