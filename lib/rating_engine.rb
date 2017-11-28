class RatingEngine

  Factors = {
    :one => {
      :name => "Number of Accounts",
      :desc => "How many accounts do you have?",
      :proc => Proc.new do |engine|
        case cnt = engine.total_accounts
        when 0 then [cnt,-3]
        when 1 then [cnt,-1]
        when 2 then [cnt,1]
        when 3 then [cnt,3]
        when 4 then [cnt,2]
        else [cnt,-1]
        end
      end
    },

    :two => {
      :name => "Accounts Positive Balance",
      :desc => "How many accounts do you have that positive cash flow?",
      :proc => Proc.new do |engine|
        cnt = engine.total_positive_accounts
        case engine.total_accounts - cnt
        when 0 then [cnt, 2]
        when 1 then [cnt, 0]
        when 2 then [cnt,-1]
        when 3 then [cnt,-2]
        when 4 then [cnt,-3]
        else [cnt,-4]
        end
      end
    },

    :three => {
      :name => "Average Transactions per Account per Month",
      :desc => "How many transactions per account on average?",
      :proc => Proc.new do |engine|
        case cnt = engine.average_transactions_per_month
        when (0..100) then [cnt, 0]
        when (100..400) then [cnt, 1]
        when (400..800) then [cnt, 2]
        when (800..1000) then [cnt,1]
        when (1000..1200) then [cnt,1]
        else [cnt,-1]
        end
      end
    },

    :four => {
      :name => "Regularly rental payments",
      :desc => "Are rental payments being done regularly?",
      :proc => Proc.new do |engine|
        rental_payments = engine.user.transactions_by_month("rent")
        num_months      = rental_payments.keys.count
        num_of_payments = rental_payments.values.map(&:count).sum
        cnt             = num_of_payments
        case num_months - num_of_payments
        when (-10..-1) then [cnt, -1]
        when 0 then [cnt, 3]
        when 1 then [cnt, 1]
        when 2 then [cnt, 0]
        else [cnt,-3]
        end
      end
    },

    :five => {
      :name => "Last Transaction Date - how long ago (in days)?",
      :desc => "Are account date up-to-date?",
      :proc => Proc.new do |engine|
        last_date   = engine.last_transaction_date || (Date.today-100)
        num_of_days = (Date.today - last_date).to_i
        case cnt = num_of_days
        when (0..3) then [cnt, 3]
        when (3..6) then [cnt, 2]
        when (6..10) then [cnt, 1]
        when (10..30) then [cnt, -1]
        when (30..60) then [cnt, -2]
        else [cnt,-3]
        end
      end
    },

    :six => {
      :name => "Are accounts connected to Figo or uploaded? (Percent)",
      :desc => "Is account data trustworthy or manually uploaded?",
      :proc => Proc.new do |engine|
        case cnt = engine.figo_connected_accounts_ratio
        when (0..30)  then [cnt, -2]
        when (30..50) then [cnt, -1]
        when (50..70) then [cnt, 1]
        when (70..90) then [cnt, 2]
        else [cnt,3]
        end
      end
    },
  }


  attr_reader :user

  def initialize(user)
    @user = user
  end

  def accounts
    user.accounts
  end

  def total_accounts
    user.accounts.count
  end

  def figo_connected_accounts_ratio
    tot = total_accounts
    return 0 if tot == 0

    c = user.accounts.inject([0,0]) do |counter,acc|
      acc.is_figo_connected? ? counter[0] += 1 : counter[1] += 1
      counter
    end

    ((c[0] / tot.to_f) * 100).to_i
  end

  def total_positive_accounts
    user.accounts.in_credit.count
  end

  def average_transactions_per_month
    user.transactions_by_month.map { |_,trans| trans.count }.average
  end

  def last_transaction_date
    user.last_transaction_date
  end

  def rating
    Factors.map do |_, factor|
      factor[:proc].call(self).last
    end.sum
  end

  def tablize_ratings
    Factors.map do |_, factor|
      val     = factor[:proc].call(self)
      { :desc   => factor[:desc],
        :name   => factor[:name],
        :rating => val.last,
        :value  => val.first
      }
    end
  end
end
