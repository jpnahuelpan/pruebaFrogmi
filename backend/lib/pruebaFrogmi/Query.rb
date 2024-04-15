class Query
  def initialize(coll, page, per_page, mag_type)
    @_coll = coll
    @_page = page
    @_per_page = per_page
    @_mag_type = mag_type
  end

  def formating_features_for_serve
    range = self.get_range
    query = self.query
    data = {
      data: query[:data][range[:init], range[:limit]],
      pagination: {
        current_page: @_page,
        total: query[:count],
        per_page: @_per_page
      }
    }
    data
  end

  private

  def query
    if @_mag_type.nil?
      self.query_all
    else
      self.query_by_mag_type
    end
  end

  def query_all
    list = []
    query = @_coll.find()
    query.each do |document|
      list.push(document)
    end
    {data: list, count: query.count}
  end

  def query_by_mag_type
    list = []
    query = @_coll.find()
    query.each do |document|
      if @_mag_type.include?(document['attributes']['mag_type'])
        list.push(document)
      end
    end
    {data: list, count: query.count}
  end

  def get_range
    i = @_per_page.to_i * (@_page.to_i - 1)
    e = @_per_page.to_i
    {init: i, limit: e}
  end
end
