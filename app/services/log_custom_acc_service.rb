class LogCustomAccService
  def self.create_log(acc: nil, user: nil)
    begin
      LogCustomAccount.create(acct_id: acc, user_id: user)
      return true
    rescue StandardError => e
      return false, e.message
    end
  end
end