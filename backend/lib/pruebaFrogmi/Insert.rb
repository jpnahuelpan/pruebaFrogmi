class InsertFeatures
  def initialize(coll)
    @_coll = coll
  end

  def instert_init_data(data)
    all_data = self.formating_init_data(data)
    result = @_coll.insert_many(all_data)
    "#{result.inserted_count} features inserted"
  end

  def updating_features(data)
    data.each do |f|
      most_recente_time = self.get_max_key('attributes.time')
      if f['properties']['time'] > most_recente_time && self.insertable_feature(f)
        id = self.get_max_key('_id')
        @_coll.insert_one(formating_feature(f, id + 1))
      end
    end
  end

  private

  def formating_feature(feature, id)
    data_struct = {
      _id: id,
      type: feature['type'],
      attributes: {
        external_id: feature['id'],
        magnitude: feature['properties']['mag'],
        place: feature['properties']['place'],
        time: feature['properties']['time'],
        tsunami: feature['properties']['tsunami'],
        mag_type: feature['properties']['magType'],
        title: feature['properties']['title'],
        coordinates: {
          longitude: feature['geometry']['coordinates'][0],
          latitude: feature['geometry']['coordinates'][1]
        }
      },
      links: {
        external_url: feature['properties']['url']
      }
    }
    data_struct
  end

  def formating_init_data(data)
    id = 1
    data_formated = []
    data.each do |f|
      if self.insertable_feature(f)
        data_formated.push(formating_feature(f, id))
        id += 1
      end
    end
    data_formated
  end

  def get_max_key(key)
    max = @_coll.aggregate([
      { '$group': { '_id': nil, 'max_valor': { '$max': "$#{key}" } } },
      { '$sort': { 'max_valor': -1 } },
      { '$limit': 1 }
    ])
    max.first['max_valor']
  end

  def any_value_nil(f)
    f['properties']['title'].nil? || f['properties']['place'].nil? || f['properties']['url'].nil? || f['properties']['magType'].nil? || f['geometry']['coordinates'][0].nil? || f['geometry']['coordinates'][1].nil?
  end

  def any_value_out_ranges(f)
    magnitude = (-1.0..10.0)
    latitude = (-90.0..90.0)
    longitude = (-180.0..180)
    !magnitude.include?(f['properties']['mag']) || !longitude.include?(f['geometry']['coordinates'][0]) || !latitude.include?(f['geometry']['coordinates'][1])
  end

  def insertable_feature(f)
    !self.any_value_nil(f) && !self.any_value_out_ranges(f)
  end
end

class InsertComments
  def initialize(coll, data, id_feature)
    @_coll = coll
    @_data = data
    @_id_feature = id_feature
  end

  def response_for_post
    self.insert_comment
    self.formating_response
  end

  private

  def get_all_comments
    list = []
    query = @_coll.find({feature_id: @_id_feature})
    query.each do |c|
      list.push(c)
    end
    list
  end

  def insert_comment
    comment = self.formating_comment(@_data['body'], @_id_feature)
    @_coll.insert_one(comment)
  end

  def formating_comment(body, id_feature)
    data = {
      feature_id: id_feature,
      body: body
    }
    data
  end

  def formating_response
    query = self.get_all_comments
    response = {
      message: 'Comentario ingresado exitosamente.',
      comments: query
    }
    response
  end
end
