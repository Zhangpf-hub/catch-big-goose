mergeInto(LibraryManager.library, {
  GoosePrepareWechatVideo: function(index, requestId, receiverPointer) {
    var receiver = UTF8ToString(receiverPointer);
    var reply = function(path, error) {
      try { SendMessage(receiver, 'OnWeChatVideoPath', JSON.stringify({ requestId: requestId, path: path || '', error: error || '' })); } catch (_) {}
    };
    if (typeof wx === 'undefined') { reply('', 'Not running in WeChat'); return; }
    wx.loadSubpackage({
      name: 'goose-media',
      success: function() {
        try {
          var fs = wx.getFileSystemManager();
          var manifest = JSON.parse(fs.readFileSync('media/manifest.json', 'utf8'));
          var file = manifest.files[index];
          if (!file) throw new Error('Video index missing');
          var folder = wx.env.USER_DATA_PATH + '/goose-media';
          try { fs.mkdirSync(folder, true); } catch (_) {}
          var target = folder + '/' + file.sha256 + '.mp4';
          try {
            fs.accessSync(target);
            var result = fs.statSync(target); var stat = result.stats || result;
            if (file.bytes && Number(stat.size) !== file.bytes) { fs.unlinkSync(target); }
            else { reply(target, ''); return; }
          } catch (_) {}
          // Copy through the native filesystem. Do not duplicate an entire MP4
          // into a JS ArrayBuffer while Unity's model heap is still resident.
          if (typeof fs.copyFile !== 'function') throw new Error('Native file copy unavailable');
          fs.copyFile({ srcPath: 'media/' + file.name, destPath: target,
            success: function() { reply(target, ''); },
            fail: function(error) { reply('', error.errMsg || 'Video cache copy failed'); }
          });
        } catch (error) { reply('', String(error)); }
      },
      fail: function(error) { reply('', error.errMsg || 'Video subpackage failed'); }
    });
  }
});
