#!/usr/bin/env ruby
=begin
Track is a collection of TrackSegments making up a Track
=end
class Track
  def initialize(*args, name:nil)
    @name = name
    @segments = args
    #@coordinates = coordinates
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
    @segments.each_with_index do |track_segment, index|

      if index > 0
        json_string += ","
      end

      json_string += '['

      track_segment_string = ''
      #can be futher done to take coordinates directly instead of the tracksegment
      track_segment.coordinates.each do |coordinate|
        if track_segment_string != ''
          track_segment_string += ','
        end
        track_segment_string = coordinate.get_coordinate_json(track_segment_string)
      end

      json_string+=track_segment_string
      json_string+=']'

    end

    json_string + ']}}'

  end


end


=begin
TrackSegment is a collection of points that make up a segment of a larger Track
=end
class TrackSegment
  attr_reader :coordinates
  def initialize(coordinates)
    @coordinates = coordinates
  end
end

=begin
Point is a collection of coordinates (longitude, latitude and elevation) that can be used to make up Tracks and Track segments
=end
class Point
  attr_reader :lat, :lon, :ele
  def initialize(lon, lat, ele=nil)
    @lon = lon
    @lat = lat
    @ele = ele
  end

=begin
get_coordinate_json(...) creates the json string for the coordinates to be sent to the track and waypoint
Adds the coordinate parts (longitude, latitude, and elevation, if it has one) to the json string
=end

  def get_coordinate_json(string)

    string += "[#{@lon},#{@lat}"
    if @ele != nil
      string += ",#{@ele}"
    end

    string += ']'
  end

end

=begin
Waypoint is a subclass of point, it has the same methods as the superclass aswell as the same root attributes lon = longitude, lat = latitude, and ele = elevation, but it has two more as well, a name and type,
=end
class Waypoint < Point

  attr_reader :lat, :lon, :ele, :name, :type

  def initialize(lon, lat, ele=nil, name=nil, type=nil)
    super(lon, lat, ele)
    @name = name
    @type = type
  end

  #get_json() creates the json string for the waypoint class
  def get_json(indent=0)
    json_string = '{"type": "Feature",'
    json_string += '"geometry": {"type": "Point","coordinates": '

    json_string = get_coordinate_json(json_string)

    json_string += '},'

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

=begin
World creates the world state geojson containing all points, Tracksegments and Tracks that make up the broader context of the code
=end
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
  #main makes the initial world state of the coordinates
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

  t = Track.new(TrackSegment.new(ts1), TrackSegment.new(ts2), name:"track 1")
  t2 = Track.new(TrackSegment.new(ts3), name:"track 2")

  #world takes a name and list of waypoints, or tracks, or waypoints and tracks
  world = World.new("My Data", [w, w2, t, t2])

  puts world.to_geojson()
end

if File.identical?(__FILE__, $0)
  main()
end

