#!/usr/bin/env ruby
class Track
  def initialize(segments, name=nil)
    @name = name
    segment_objects = []
    segments.each do |coordinates|
      segment_objects.append(TrackSegment.new(coordinates))
    end
    @segments = segment_objects
  end

=begin
get_json() creates the json string for the track class
=end

  def get_json()
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
    @segments.each_with_index do |coordinates, index|

      if index > 0
        json_string += ","
      end

      json_string += '['

      track_segment_string = ''
      coordinates.coordinates.each do |coordinate|
        track_segment_string = get_coordinate_json(track_segment_string, coordinate)
      end

      json_string+=track_segment_string
      json_string+=']'

    end

    json_string + ']}}'

  end

=begin
get_coordinate_json(...) creates the json string for the coordinates to be sent to the track
Adds the coordinate parts (longitude, latitude, and elevation) to the json string
=end

  def get_coordinate_json(track_segment_string, coordinate)

    if track_segment_string != ''
      track_segment_string += ','
    end
    track_segment_string += '['
    track_segment_string += "#{coordinate.lon},#{coordinate.lat}"
    if coordinate.ele != nil
      track_segment_string += ",#{coordinate.ele}"
    end
    track_segment_string += ']'
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

  #get_json() creats the json string for the waypoint class

  def get_json(indent=0)
    json_string = '{"type": "Feature",'
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
      if type != nil
        if name != nil
          json_string += ','
        end
        json_string += '"icon": "' + @type + '"'
      end
      json_string += '}'
    end

    json_string += "}"
    return json_string
  end

end

class World
  def initialize(name, waypoints_and_tracks)
    @name = name
    @features = waypoints_and_tracks
  end

=begin
  writes the json string for all waypoints and tracks
=end
  def to_geojson(indent=0)
    geo_json_string = '{"type": "FeatureCollection","features": ['
    @features.each_with_index do |waypoint_or_track, index|
      if index != 0
        geo_json_string +=","
      end

      geo_json_string += waypoint_or_track.get_json

    end

    geo_json_string + "]}"
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

  #world takes a name and list of waypoints, or tracks, or waypoints and tracks
  world = World.new("My Data", [w, w2, t, t2])

  puts world.to_geojson()
end

if File.identical?(__FILE__, $0)
  main()
end

