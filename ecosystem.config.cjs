// pm2 process file for everloop.
//
// Each fire runs ONE tick in a FRESH process (fresh context), then exits — pm2 re-launches it on
// the cron schedule. No single process accumulates context, so the loop runs indefinitely.
//
//   pm2 start ecosystem.config.cjs   # start
//   pm2 logs everloop                # watch
//   pm2 stop everloop                # stop
//   pm2 save && pm2 startup          # persist across reboots
module.exports = {
  apps: [{
    name: "everloop",
    script: "everloop/tick.sh",
    interpreter: "bash",
    cwd: __dirname,
    cron_restart: "*/15 * * * *",   // one tick every 15 min; tune to taste
    autorestart: false,             // exactly one tick per fire, then exit
    instances: 1,
    // env: { EVERLOOP_STEP: "examples/counter/step.sh" },  // swap for your own step / a Claude /tick
    merge_logs: true,
    time: true
  }]
};
