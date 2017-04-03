require_relative '../config/sequel'

module ExpenseTracker
  RecordResult = Struct.new(:success?, :expense_id, :error_message)

  class Ledger
    REQUIRED = ['payee', 'amount', 'date']

    def record(expense)
      if missing_keys?(expense)
        message = "Invalid expense: #{@missing_keys.join(',')} is required"
        return RecordResult.new(false, nil, message)
      end

      DB[:expenses].insert(expense)
      id = DB[:expenses].max(:id)
      RecordResult.new(true, id, nil)
    end

    def expenses_on(date)
      DB[:expenses].where(date: date).all
    end

    private

    def missing_keys?(expense)
      @missing_keys = REQUIRED - expense.keys
      @missing_keys.map! { |k| "`#{k}`" }
      @missing_keys.any?
    end
  end
end
