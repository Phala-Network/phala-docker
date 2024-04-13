#!/usr/bin/env python3

import sentry_sdk
sentry_sdk.init(
    dsn="https://12350743984f2a5f070302da860c72cc@o4507076202856448.ingest.us.sentry.io/4507076282679296",
    enable_tracing=True,
)

import os, random, re, requests, subprocess, time

def telemetry(port):
    m = {}
    m['pruntime_info'] = requests.get(f'http://127.0.0.1:{port}/get_info').text
    m['lscpu'] = subprocess.run(['lscpu'], stdout=subprocess.PIPE).stdout.decode('utf-8')
    m['lsmem'] = subprocess.run(['lsmem'], stdout=subprocess.PIPE).stdout.decode('utf-8')
    m['cpuinfo'] = subprocess.run(['grep "stepping\|model\|microcode" /proc/cpuinfo'], shell = True, stdout=subprocess.PIPE).stdout.decode('utf-8')
    requests.post(os.environ.get('TELEMETRY_URL'), json=m)

if __name__ == '__main__':
    port = 8000
    if 'EXTRA_OPTS' in os.environ:
        match = re.match(r'.*--port\s*[=| ]\s*(\d+).*', os.environ.get('EXTRA_OPTS'))
        if match != None:
            for g in match.groups():
                port = int(g)
    time.sleep(120)
    while True:
        try:
            telemetry(port)
        except Exception as err:
            sentry_sdk.capture_exception(err)
            time.sleep(60)
        else:
            time.sleep(random.randint(3300, 3900))
