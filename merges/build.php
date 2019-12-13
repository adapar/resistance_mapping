<?php

// ffmpeg -i <VID> pic%04d.jpg
// ffmpeg -start_number 1 -i pass1_%04d.jpg -vcodec mpeg4 final.mp4

function build_command($min, $max, $image_fn_template, $weight, $power, $output_fn) {
	$images = array();
	$polys = array();
	for ($pix = $min; $pix <= $max; $pix++) {
		$images[] = sprintf($image_fn_template, $pix);
		$polys[] = "{$weight},{$power}";
	}
	$images = join(' ', $images);
	$polys = join(' ', $polys);
	$command = sprintf("convert {$images} -poly '{$polys}' {$output_fn}");
	echo $command . PHP_EOL;
}

function build_pass($total, $step, $src_fn_template, $output_fn_template, $weight, $power) {
	$output_ix = 0;

	for ($min = 1; $min < ($total + 1); $min += $step) {
		$output_ix++;
		$max = $min + $step - 1;
		if ($max > $total) $max = $total;
		$output_fn = sprintf($output_fn_template, $output_ix);
		build_command($min, $max, $src_fn_template, $weight, $power, $output_fn);
	}

	return $output_ix;
}

function build_image($total, $step, $src_folder, $src_fn_template, $output_suffix, $forced_total_for_weight = null) {
	$weight = 1/$total;
	if (!is_null($forced_total_for_weight)) {
		$weight = 1/$forced_total_for_weight;
	}
	$power = 1;

	$pass = 1;

	$total = build_pass($total, $step, "{$src_folder}/{$src_fn_template}.jpg", "intermediate/pass{$pass}_%04d.jpg", $weight, $power);

	while ($total > $step) {
		$weight = 1;
		$power = 1;
		$pass++;
		$previous_pass = $pass - 1;

		$total = build_pass($total, $step, "intermediate/pass{$previous_pass}_%04d.jpg", "intermediate/pass{$pass}_%04d.jpg", $weight, $power);
	}

	$weight = 1;
	$power = 1;

	build_command(1, $total, "intermediate/pass{$pass}_%04d.jpg", $weight, $power, "final_{$output_suffix}.jpg");
}

build_image(8, 2, 'v1_tab', 'pic%04d', 'v1_tab');
build_image(13, 2, 'v2_dis', 'pic%04d', 'v1_dis');

