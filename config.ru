require './office_wars'

log = ::File.new('log/wars.log', 'a+')
$stderr.reopen(log)
$stdout.reopen(log)

run OfficeWars