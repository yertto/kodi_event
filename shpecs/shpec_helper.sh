export PATH=./bin:$PATH

subject() { eval "$cmd"; }

matches_expected_packet() { local cmd="${cmd:-$1}" bin_name="${bin_name:-$2}"
  local bin_file="${bin_file:-./shpecs/support/${bin_name}.bin}"

  describe '`'"${cmd:-echo}"'`'
    it "matches $bin_file"
      diff -u \
        <(xxd "$bin_file") \
        <(uid=1700610725 eval "$cmd" | xxd)
      assert equal $? 0
    end_
  end_
}
