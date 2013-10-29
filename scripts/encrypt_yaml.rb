#!/usr/bin/env ruby
require 'rubygems'
require 'yaml'
require 'gpgme'
require 'optparse'

def main(argv=ARGV)
  options = {}
  options[:recipients] = []

  OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} [options]"

    opts.on("--homedir HOMEDIR", "Specify your gpg homedir, defaults to $GNUPGHOME or ~/.gnupg") do |h|
      options[:homedir] = h
    end
    opts.on("-r", "--recipient RECIPIENT", "Encrypt using this key") do |r|
      options[:recipients] << r
    end
    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end
  end.parse!(argv)

  if options[:homedir]
    GPGME::Engine.home_dir = options[:homedir]
  end

  if options[:recipients].length < 1
    $stderr.print("#{$0}: at least one RECIPIENT must be specified.\n")
  end

  if argv.length < 1 or argv[0] == "-"
    input = $stdin
  else
    input = File.new(argv[0], "r")
  end

  GPGME::Ctx.new() do |ctx|
    crypto = GPGME::Crypto.new(:armor => true, :always_trust => true)
    data = encrypt_any(options[:recipients], YAML.load(input.read), crypto)
    YAML.dump(data, $stdout)
  end
end

def encrypt_any(r, d, crypto)
  if d.kind_of? String
    if !d.match(/^-----BEGIN PGP MESSAGE-----[[:space:]]*\n/)
      return encrypt_text(r,d,crypto)
    else
      return d
    end
  elsif d.kind_of? Array
    return d.map{|v| encrypt_any(r,v,crypto)}
  elsif d.kind_of? Hash
    d.each_key{|k| d[k] = encrypt_any(r,d[k],crypto)}
    return d
  else
    raise Exception, "Expected String, Array, or Hash, got #{d.class}"
  end
end

def encrypt_text(r, plain, crypto)
  begin
    cipher = crypto.encrypt(plain, :recipients => r)
  rescue GPGME::Error => e
    $stderr.print("GPGME::Error: code: #{e.code} source: #{e.source} message: #{e.message}\n")
    raise e
  end
  cipher.seek 0
  return cipher.read
end

if __FILE__ == $0
    main
end
