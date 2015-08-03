#!/usr/bin/env ruby

require 'colorize'
require 'digest'
require 'pp'

class SCO
	attr_accessor :url
	attr_accessor :orig_url
	attr_accessor :ctime
	attr_accessor :mtime
	attr_accessor :size
	attr_accessor :headers
	attr_accessor :md5
	attr_accessor :sha1
	attr_accessor :sha256
	attr_accessor :http_code

	def initialize(inputfile)
		@url = inputfile
		@ctime = File.ctime(@url)
		@mtime = File.mtime(@url)
		@size = File.size(@url)
		
		@headers = Hash.new
		contents = IO.binread(inputfile, 720)
		contents.split(/\r\n/).each do |char|
			#puts "LINE: #{char}"
			(k, v) = char.split(/: /)
			break if k.nil? && v.nil?
			bits = k.split(/\x00/)
			#puts bits.length.to_s.green
			#pp bits
			bits.each do |b|
				puts "|#{b.to_s.red}|"
				if b =~ /(http.*)/
					@orig_url = $1
					break
				else 
					@orig_url = ''
				end
			end
			if k =~ /.*(HTTP\/1.[01] [2345]\d\d \w\w*)/
				@http_code = $1
				next
			end
			if !@headers.has_key? k
				@headers[k] = v
			else 
				@headers[k] += ";#{v}"
			end
		end

		m = Digest::MD5.file @url
		@md5 = m.hexdigest

		s = Digest::SHA1.file @url
		@sha1 = s.hexdigest

		s2 = Digest::SHA256.file @url
		@sha256 = s2.hexdigest
	end

	def human_readable (size) 
		case 
		when size < 1024
			return "#{size} bytes"
		when size < 1048576
			return "#{size / 1024} KB"
		when size < 1073741824
			return "#{size / 1024 / 1024} MB"
		else
			# assume GB
			return "#{size / 1024 / 1024 / 1024} GB"
		end
	end
			

	alias new initialize
end

inputfile = ''
if ARGV.length != 1
	raise "Expecting only 1 argument: the path the cache file."
else
	inputfile = ARGV[0]
end

sco = SCO.new(inputfile)

pp sco

puts "File size is #{sco.human_readable(sco.size).to_s}."
