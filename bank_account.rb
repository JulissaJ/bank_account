
class BankTransaction
  attr_reader :date, :amount, :description, :account
  def initialize(date, amount, description, account)
    @date = date
    @amount = amount
    @description = description
    @account = account
  end

  def to_s
    "Date: #{@date} - amount: #{@amount} - #{@description} - #{@account}"
  end

  def debit?
    @amount.to_f < 0
  end

  def credit?
    @amount.to_f > 0
  end
end

class BankAccount
  attr_reader :account_type, :starting_balance, :ending_balance
  def initialize(type, starting_balance)
    @account_type = type
    @starting_balance = starting_balance.to_f
    @ending_balance = starting_balance.to_f
    @transactions = []
  end

  def to_s
    "#{@account_type} - starting balance: #{@starting_balance} - ending balance: #{@ending_balance}"
  end

  def add_transactions(transactions)
    transactions.each do |trans|
      @transactions << trans if trans.account == @account_type
      @ending_balance += trans.amount.to_f
    end
  end

  def summary
    @transactions.map { |trans| trans.description }
  end

  def currency(num)
    "$#{'%.2f' % (num)}"
  end

  def report
    array = []
    array << "==== #{@account_type} ====\n\n"
    array << "Starting Balance: #{currency(@starting_balance)}"
    array << "Ending Balance:   #{currency(@ending_balance)}\n\n"
    @transactions.each do |trans|
      if trans.credit?
        type = 'CREDIT'
      elsif trans.debit?
        type = 'DEBIT'
      end
      array << "#{currency(trans.amount)}  \t#{type}\t#{trans.date} - #{trans.description}"
    end
    array << "\n========\n"
  end
end

require 'csv'

def create_accounts(csv)
  accounts = []
  CSV.foreach(csv, headers: true) do |row|
    accounts << BankAccount.new(row[0], row[1])
  end
  accounts
end

def read_transactions(csv)
  transactions = []
  CSV.foreach(csv, headers: true) do |row|
    transactions << BankTransaction.new(row[0], row[1], row[2], row[3])
  end
  transactions
end

accounts = create_accounts('balances.csv')
accounts.each {|acc| acc.add_transactions(read_transactions('bank_data.csv'))}
accounts.each {|acc| puts acc.report}
