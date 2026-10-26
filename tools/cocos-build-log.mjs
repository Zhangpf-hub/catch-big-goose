export function inspectBuildLog(log) {
  const lines = log.split(/\r?\n/);
  const buildStart = lines.findIndex(line => line.startsWith('Start enter command build with options '));
  const startupWarnings = [];
  const errors = lines.filter((line, index) => {
    if (!/(^|[^a-z])error:/i.test(line)) return false;
    // Creator's optional information service can time out before the build starts.
    // Match only these exact startup messages; build-stage errors still fail.
    if (buildStart >= 0 && index < buildStart && (
      line === '[information] Query information: Error: GET Timeout: https://creator-api.cocos.com/information_url'
      || line === 'Error: Init information cache failed!'
    )) {
      startupWarnings.push(line);
      return false;
    }
    return !/^\[[0-9]+:.*:ERROR:ssl_client_socket_impl.*handshake failed/.test(line)
      && !/Exit process with code:null, signal:SIGTERM in task build-(script|engine)/.test(line);
  });
  return { errors, startupWarnings };
}
