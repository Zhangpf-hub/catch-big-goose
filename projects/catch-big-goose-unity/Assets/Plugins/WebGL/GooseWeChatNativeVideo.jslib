mergeInto(LibraryManager.library, {
  $GooseNativeVideo: {
    current: null,
    reply: function(state, type, error) {
      if (state.closed) return;
      try {
        SendMessage(state.receiver, 'OnWeChatVideoEvent', JSON.stringify({
          requestId: state.id, type: type, error: error || '',
          position: state.position || 0, duration: state.duration || 0
        }));
      } catch (_) { /* Unity may already be shutting down. */ }
    },
    dispose: function(state) {
      if (!state || state.closed) return;
      state.closed = true;
      if (GooseNativeVideo.current === state) GooseNativeVideo.current = null;
      var video = state.video;
      if (!video) return;
      for (var key in state.handlers) {
        var off = 'off' + key.slice(2);
        try { if (typeof video[off] === 'function') video[off](state.handlers[key]); } catch (_) {}
      }
      // Never destroy the native player from inside its own ended/error stack.
      setTimeout(function() {
        try { video.pause(); } catch (_) {}
        try { video.stop(); } catch (_) {}
        try { video.destroy(); } catch (_) {}
      }, 0);
    }
  },
  GoosePlayWechatVideo__deps: ['$GooseNativeVideo'],
  GoosePlayWechatVideo: function(pathPointer, requestId, receiverPointer, muted) {
    var state = { id: requestId, receiver: UTF8ToString(receiverPointer), closed: false,
      video: null, position: 0, duration: 0, playing: false, handlers: {} };
    GooseNativeVideo.dispose(GooseNativeVideo.current);
    GooseNativeVideo.current = state;
    try {
      if (typeof wx === 'undefined' || typeof wx.createVideo !== 'function') throw new Error('Native video API unavailable');
      var info = wx.getWindowInfo ? wx.getWindowInfo() : wx.getSystemInfoSync();
      var width = info.windowWidth || info.screenWidth || 360;
      var height = info.windowHeight || info.screenHeight || 640;
      var videoHeight = Math.min(width * 9 / 16, height * .60);
      var video = wx.createVideo({ src: UTF8ToString(pathPointer), x: 0, y: (height-videoHeight)/2,
        width: width, height: videoHeight, autoplay: false, loop: false, muted: !!muted,
        controls: false, showProgress: false, showProgressInControlMode: false,
        enableProgressGesture: false, enablePlayGesture: true, showCenterPlayBtn: true,
        underGameView: false, objectFit: 'contain', backgroundColor: '#000000' });
      state.video = video;
      var bind = function(name, callback) {
        if (typeof video[name] !== 'function') throw new Error('Missing native callback ' + name);
        state.handlers[name] = callback; video[name](callback);
      };
      bind('onPlay', function() { if (state.closed) return; state.playing=true; GooseNativeVideo.reply(state,'play'); });
      bind('onPause', function() { GooseNativeVideo.reply(state,'pause'); });
      bind('onTimeUpdate', function(event) {
        if (state.closed) return;
        var position = Number(event.position), duration = Number(event.duration);
        if (isFinite(position) && position >= 0) state.position = Math.max(state.position,position);
        if (isFinite(duration) && duration > 0) state.duration = duration;
        GooseNativeVideo.reply(state,'time');
      });
      bind('onEnded', function() {
        if (state.closed) return;
        var complete = state.playing && state.duration > 0 && state.position >= state.duration-1;
        GooseNativeVideo.reply(state,complete?'ended':'error',complete?'':'Incomplete native playback');
        GooseNativeVideo.dispose(state);
      });
      bind('onError', function(error) {
        if (state.closed) return;
        GooseNativeVideo.reply(state,'error',error && error.errMsg || 'Native video failed');
        GooseNativeVideo.dispose(state);
      });
      video.play();
    } catch (error) {
      GooseNativeVideo.reply(state,'error',String(error));GooseNativeVideo.dispose(state);
    }
  },
  GooseStopWechatVideo__deps: ['$GooseNativeVideo'],
  GooseStopWechatVideo: function(requestId) {
    var state=GooseNativeVideo.current;
    if(state&&state.id===requestId)GooseNativeVideo.dispose(state);
  }
});
