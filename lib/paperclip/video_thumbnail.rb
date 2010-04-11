module Paperclip
  class VideoThumbnail < Processor
 
    attr_accessor :time_offset, :geometry, :whiny
 
    def initialize(file, options = {}, attachment = nil)
      super
      
      cmd = %Q[-i "#{File.expand_path(file.path)}" -vstats ]
      success = Paperclip.run('ffmpeg', cmd, 1)
      Rails.logger.info success
      puts success
      
      # @time_offset = options[:time_offset] || '-4'
      #       unless options[:geometry].nil? || (@geometry = Geometry.parse(options[:geometry])).nil?
      #         @geometry.width = (@geometry.width / 2.0).floor * 2.0
      #         @geometry.height = (@geometry.height / 2.0).floor * 2.0
      #         @geometry.modifier = ''
      #       end
      @whiny = options[:whiny].nil? ? true : options[:whiny]
      @basename = File.basename(file.path, File.extname(file.path))
    end
 
    def make
      dst = Tempfile.new([ @basename, 'jpg' ].compact.join(''))
      dst.binmode
      
      cmd = %Q[-i "#{File.expand_path(file.path)}" -an -ss 00:00:05 -r 1 -vframes 1 -y ]
      cmd << %Q["#{File.expand_path(dst.path)}" ]
      cmd << "-s #{geometry.to_s} " unless geometry.nil?
      
      begin
        success = Paperclip.run('ffmpeg', cmd)
      rescue PaperclipCommandLineError
        raise PaperclipError, "There was an error processing the thumbnail for #{@basename}" if whiny
      end
      dst
    end
  end
end