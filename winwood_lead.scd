// Adapted for Sonic Pi from
//   https://raw.githubusercontent.com/supercollider/supercollider/develop/examples/demonstrations/stealthissound.scd
// Published there under GPL v3, so re-published under the same terms, see:
//   https://www.gnu.org/licenses/gpl-3.0.en.html
// Date of modification: 05.01.2021

(
SynthDef('sonic-pi-winwood_lead', {|
	note = 69, note_slide = 0, note_slide_shape = 1, note_slide_curve = 0,
	amp = 1, amp_slide = 0, amp_slide_shape = 1, amp_slide_curve = 0,
	pan = 0, pan_slide = 0, pan_slide_shape = 1, pan_slide_curve = 0,
	attack = 0.01, decay = 0, sustain = 1, release = 1,
	attack_level = 1, decay_level = 0.5, sustain_level = 0,
	cutoff = 119, cutoff_slide = 0, cutoff_slide_shape = 1, cutoff_slide_curve = 1,
	rq = 0.8, lfowidth = 0.01, lforate = 8, lagamount = 0.01,
	seed = 0, rand_buf = 0,
	out_bus = 0|

	var freq, snd, pulse, env, lfo;
	var rand_val;

	note = note.midicps;
	note = note.varlag(note_slide, note_slide_curve, note_slide_shape);
	decay_level = Select.kr(decay_level < 0, [decay_level, sustain_level]);
	amp = amp.varlag(amp_slide, amp_slide_curve, amp_slide_shape);
	pan = pan.varlag(pan_slide, pan_slide_curve, pan_slide_shape);

	cutoff = cutoff.midicps;
	cutoff = cutoff.varlag(cutoff_slide, cutoff_slide_curve, cutoff_slide_shape);

	rand_val = BufRd.kr(1, rand_buf, seed, 1);

	lfo = LFTri.kr(lforate,(rand_val*2.0)!2);

	pulse = Mix(Pulse.ar((note.lag(lagamount))*[1,1.001]*(1.0+(lfowidth*lfo)),[0.2,0.19]))*0.5;

	snd =  RLPF.ar(pulse,cutoff,rq);

	// Remove low end
	snd = BLowShelf.ar(snd,351,1.0,-9);

	env = Env.new(
		[0, attack_level, decay_level, sustain_level, 0],
		[attack,decay,sustain,release],
		\lin
	);

	snd = Pan2.ar(Mix(snd) * 2 * EnvGen.kr(env, doneAction: 2), pan);

	Out.ar(out_bus, snd * amp);
}).writeDefFile("/home/bmarx/music/sonic_pi/synthdefs/compiled/");
)