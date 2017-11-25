default['centos-oracle-prep'] =
{
  'images_repo' => 'https://storage.googleapis.com/windchill/',
  'images' => %w( linuxamd64_12102_database_1of2.zip linuxamd64_12102_database_2of2.zip ),
  'sums' => %w(
    080435a40bd4c8dff6399b231a808e9a
    30f20ef9437442b8282ce3984546c982
  ),
  'version' => '12',
  'revision' => '102',
}
