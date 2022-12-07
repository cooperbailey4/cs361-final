#!/usr/bin/env ruby
#j = json_string
class Track
  def initialize(segments, name=nil)
    @name = name
    segment_objects = []
    segments.each do |coordinates|
      segment_objects.append(TrackSegment.new(coordinates))
    end
    # set segments to segment_objects
    @segments = segment_objects
  end

  def get_track_json()
    json_string = '{'
    json_string += '"type": "Feature", '

    if @name != nil
      json_string += '"properties": {'
      json_string += '"title": "' + @name + '"'
      json_string += '},'
    end

    json_string += '"geometry": {'
    json_string += '"type": "MultiLineString",'
    json_string +='"coordinates": ['
    # Loop through all the segment objects
    @segments.each_with_index do |coordinates, index|

      if index > 0
        json_string += ","
      end

      json_string += '['
      # Loop through all the coordinates in the segment
      tsj = ''

      coordinates.coordinates.each do |coordinate|

        if tsj != ''
          tsj += ','
        end
        # Add the coordinate
        tsj += '['
        tsj += "#{coordinate.lon},#{coordinate.lat}"
        if coordinate.ele != nil
          tsj += ",#{coordinate.ele}"
        end
        tsj += ']'

      end

      json_string+=tsj
      json_string+=']'

    end

    json_string + ']}}'

  end
end

class TrackSegment
  attr_reader :coordinates
  def initialize(coordinates)
    @coordinates = coordinates
  end
end

class Point

  attr_reader :lat, :lon, :ele

  def initialize(lon, lat, ele=nil)
    @lon = lon
    @lat = lat
    @ele = ele
  end
end

class Waypoint

  attr_reader :lat, :lon, :ele, :name, :type

  def initialize(lon, lat, ele=nil, name=nil, type=nil)
    @lat = lat
    @lon = lon
    @ele = ele
    @name = name
    @type = type
  end

  def get_waypoint_json(indent=0)
    json_string = '{"type": "Feature",'
    # if name is not nil or type is not nil
    json_string += '"geometry": {"type": "Point","coordinates": '
    json_string += "[#{@lon},#{@lat}"

    if ele != nil
      json_string += ",#{@ele}"
    end

    json_string += ']},'

    if name != nil or type != nil
      json_string += '"properties": {'
      if name != nil
        json_string += '"title": "' + @name + '"'
      end
      if type != nil  # if type is not nil (not helpful comment)
        if name != nil
          json_string += ','
        end
        json_string += '"icon": "' + @type + '"'  # type is the icon (dont think this is helpful)
      end
      json_string += '}'
    end

    json_string += "}"
    return json_string
  end

end

class World
  def initialize(name, things)
    @name = name
    @features = things
  end

  #is this necessary?
  # def add_feature(f)
  #   @features.append(t)
  # end

  def to_geojson(indent=0)
    # Write stuff
    s = '{"type": "FeatureCollection","features": ['
    @features.each_with_index do |f,i|
      if i != 0
        s +=","
      end

      if f.class == Track
          s += f.get_track_json
      elsif f.class == Waypoint
          s += f.get_waypoint_json
      end

    end

    s + "]}"
  end

end

def main()
  #main makes the world state of the coordinates
  w = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
  w2 = Waypoint.new(-121.5, 45.6, nil, "store", "dot")
  ts1 = [
  Point.new(-122, 45),
  Point.new(-122, 46),
  Point.new(-121, 46),
  ]

  ts2 = [ Point.new(-121, 45), Point.new(-121, 46), ]

  ts3 = [
    Point.new(-121, 45.5),
    Point.new(-122, 45.5),
  ]

  t = Track.new([ts1, ts2], "track 1")
  t2 = Track.new([ts3], "track 2")

  world = World.new("My Data", [w, w2, t, t2])

  puts world.to_geojson()
end

if File.identical?(__FILE__, $0)
  main()
end

