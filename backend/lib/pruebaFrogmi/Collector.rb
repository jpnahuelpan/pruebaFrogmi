class Collector
  ENDPOINT = '/earthquakes/feed/v1.0/summary/all_month.geojson'
  def initialize(conn)
    @_conn = conn
  end

  def get_all
    response = @_conn.get(ENDPOINT)
    if response.status == 200
      response.body
    else
      response = "Error: #{response.status}"
    end
  end

  def get_by_key(key)
    response = self.get_all
    response[key]
  end
end
