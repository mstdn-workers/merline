require 'test/unit'

test_strings = {
  :media => [
    {:str => '<a href="https://www.youtube.com/watch?v=ABCDEF0123456789" rel="nofollow noopener" target="_blank"><span class="invisible">https://www.</span><span class="ellipsis">youtube.com/watch?v=ABCDEF0</span><span class="invisible">123456789</span></a>',
     :expect => '[media: https://www.youtube.com/watch?v=ABCDEF0123456789]'},
    {:str => '<a href="https://mstdn-workers.com/media/0123456789ABCDEF" rel="nofollow noopener" target="_blank"><span class="invisible">https://</span><span class="ellipsis">mstdn-workers.com/media/0123456</span><span class="invisible">789ABCDEF</span></a>',
     :expect => '[media: https://mstdn-workers.com/media/0123456789ABCDEF]'},
    {:str => 'some texts<a href="https://mstdn-workers.com/media/aBCDE-f01234567" rel="nofollow noopener" target="_blank"><span class="invisible">https://</span><span class="ellipsis">mstdn-workers.com/media/aBCDE-</span><span class="invisible">f01234567</span></a>',
     :expect => '[media: https://mstdn-workers.com/media/aBCDE-f01234567]'},
  ],
  :link => [
    {:str => '<a href="http://amzn.to/1Q84" rel="nofollow noopener" target="_blank"><span class="invisible">http://</span><span class="">amzn.to/1Q84</span><span class="invisible"></span></a>',
     :expect => 'http://amzn.to/1Q84'},
    {:str => '<a href="http://ik1-331-25647.vs.sakura.ne.jp:8080/redmine/projects/mstdn-workers/wiki/%E7%A4%BE%E7%95%9C%E4%B8%BC%E8%AA%9E%E9%8C%B2#section-7" rel="nofollow noopener" target="_blank"><span class="invisible">http://</span><span class="ellipsis">ik1-331-25647.vs.sakura.ne.jp:</span><span class="invisible">8080/redmine/projects/mstdn-workers/wiki/%E7%A4%BE%E7%95%9C%E4%B8%BC%E8%AA%9E%E9%8C%B2#section-7</span></a>',
     :expect => 'http://ik1-331-25647.vs.sakura.ne.jp:8080/redmine/projects/mstdn-workers/wiki/%E7%A4%BE%E7%95%9C%E4%B8%BC%E8%AA%9E%E9%8C%B2#section-7'},
  ],
  :hashtag => [
    {:str => '<a href="https://mstdn-workers.com/tags/merline" class="mention hashtag">#<span>merline</span></a>',
     :expect => '#merline'},
  ]
}
