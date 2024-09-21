# example_usage.rb
require_relative "turndown_service"

html_input = <<~HTML
        <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="utf-8">
    <title>turndown test runner</title>
    <link rel="stylesheet" href="../node_modules/turndown-attendant/dist/styles.css">
  </head>
  <body>

  <!-- TEST CASES -->

  <div class="case" data-name="p">
    <div class="input"><p>Lorem ipsum</p></div>
    <pre class="expected">Lorem ipsum</pre>
  </div>

  <div class="case" data-name="multiple ps">
    <div class="input">
      <p>Lorem</p>
      <p>ipsum</p>
      <p>sit</p>
    </div>
    <pre class="expected">Lorem

  ipsum

  sit</pre>
  </div>

  <div class="case" data-name="em">
    <div class="input"><em>em element</em></div>
    <pre class="expected">_em element_</pre>
  </div>

  <div class="case" data-name="i">
    <div class="input"><i>i element</i></div>
    <pre class="expected">_i element_</pre>
  </div>

  <div class="case" data-name="strong">
    <div class="input"><strong>strong element</strong></div>
    <pre class="expected">**strong element**</pre>
  </div>

  <div class="case" data-name="b">
    <div class="input"><b>b element</b></div>
    <pre class="expected">**b element**</pre>
  </div>

  <div class="case" data-name="code">
    <div class="input"><code>code element</code></div>
    <pre class="expected">`code element`</pre>
  </div>

  <div class="case" data-name="code containing a backtick">
    <div class="input"><code>There is a literal backtick (`) here</code></div>
    <pre class="expected">``There is a literal backtick (`) here``</pre>
  </div>

  <div class="case" data-name="code containing three or more backticks">
    <div class="input"><code>here are three ``` here are four ```` that's it</code></div>
    <pre class="expected">`here are three ``` here are four ```` that's it`</pre>
  </div>

  <div class="case" data-name="code containing one or more backticks">
    <div class="input"><code>here are three ``` here are four ```` here is one ` that's it</code></div>
    <pre class="expected">``here are three ``` here are four ```` here is one ` that's it``</pre>
  </div>

  <div class="case" data-name="code starting with a backtick">
    <div class="input"><code>`starting with a backtick</code></div>
    <pre class="expected">`` `starting with a backtick ``</pre>
  </div>

  <div class="case" data-name="code containing markdown syntax">
    <div class="input"><code>_emphasis_</code></div>
    <pre class="expected">`_emphasis_`</pre>
  </div>

  <div class="case" data-name="code containing markdown syntax in a span">
    <div class="input"><code><span>_emphasis_</span></code></div>
    <pre class="expected">`_emphasis_`</pre>
  </div>

  <div class="case" data-name="h1">
    <div class="input"><h1>Level One Heading</h1></div>
    <pre class="expected">Level One Heading
  =================</pre>
  </div>

  <div class="case" data-name="escape = when used as heading">
    <div class="input">===</div>
    <pre class="expected">===</pre>
  </div>

  <div class="case" data-name="not escaping = outside of a heading">
    <div class="input">A sentence containing =</div>
    <pre class="expected">A sentence containing =</pre>
  </div>

  <div class="case" data-name="h1 as atx" data-options='{"headingStyle":"atx"}'>
    <div class="input"><h1>Level One Heading with ATX</h1></div>
    <pre class="expected"># Level One Heading with ATX</pre>
  </div>

  <div class="case" data-name="h2">
    <div class="input"><h2>Level Two Heading</h2></div>
    <pre class="expected">Level Two Heading
  -----------------</pre>
  </div>

  <div class="case" data-name="h2 as atx" data-options='{"headingStyle":"atx"}'>
    <div class="input"><h2>Level Two Heading with ATX</h2></div>
    <pre class="expected">## Level Two Heading with ATX</pre>
  </div>

  <div class="case" data-name="h3">
    <div class="input"><h3>Level Three Heading</h3></div>
    <pre class="expected">### Level Three Heading</pre>
  </div>

  <div class="case" data-name="heading with child">
    <div class="input"><h4>Level Four Heading with <code>child</code></h4></div>
    <pre class="expected">#### Level Four Heading with `child`</pre>
  </div>

  <div class="case" data-name="invalid heading">
    <div class="input"><h7>Level Seven Heading?</h7></div>
    <pre class="expected">Level Seven Heading?</pre>
  </div>

  <div class="case" data-name="hr">
    <div class="input"><hr></div>
    <pre class="expected">* * *</pre>
  </div>

  <div class="case" data-name="hr with closing tag">
    <div class="input"><hr></hr></div>
    <pre class="expected">* * *</pre>
  </div>

  <div class="case" data-name="hr with option" data-options='{"hr": "- - -"}'>
    <div class="input"><hr></div>
    <pre class="expected">- - -</pre>
  </div>

  <div class="case" data-name="br">
    <div class="input">More<br>after the break</div>
    <pre class="expected">More
  after the break</pre>
  </div>

  <div class="case" data-name="br with visible line-ending" data-options='{"br": "\\"}'>
    <div class="input">More<br>after the break</div>
    <pre class="expected">More\
  after the break</pre>
  </div>

  <div class="case" data-name="img with no alt">
    <div class="input"><img src="http://example.com/logo.png" /></div>
    <pre class="expected">![](http://example.com/logo.png)</pre>
  </div>

  <div class="case" data-name="img with relative src">
    <div class="input"><img src="logo.png"></div>
    <pre class="expected">![](logo.png)</pre>
  </div>

  <div class="case" data-name="img with alt">
    <div class="input"><img src="logo.png" alt="img with alt"></div>
    <pre class="expected">![img with alt](logo.png)</pre>
  </div>

  <div class="case" data-name="img with no src">
    <div class="input"><img></div>
    <pre class="expected"></pre>
  </div>

  <div class="case" data-name="img with a new line in alt">
    <div class="input"><img src="logo.png" alt="img with
      alt"></div>
    <pre class="expected">![img with
  alt](logo.png)</pre>
  </div>

  <div class="case" data-name="img with more than one new line in alt">
    <div class="input"><img src="logo.png" alt="img with

      alt"></div>
    <pre class="expected">![img with
  alt](logo.png)</pre>
  </div>

  <div class="case" data-name="img with new lines in title">
    <div class="input"><img src="logo.png" title="the

      title"></div>
    <pre class="expected">![](logo.png "the
  title")</pre>
  </div>

  <div class="case" data-name="a">
    <div class="input"><a href="http://example.com">An anchor</a></div>
    <pre class="expected">[An anchor](http://example.com)</pre>
  </div>

  <div class="case" data-name="a with title">
    <div class="input"><a href="http://example.com" title="Title for link">An anchor</a></div>
    <pre class="expected">[An anchor](http://example.com "Title for link")</pre>
  </div>

  <div class="case" data-name="a with multiline title">
    <div class="input"><a href="http://example.com" title="Title for

      link">An anchor</a></div>
    <pre class="expected">[An anchor](http://example.com "Title for
  link")</pre>
  </div>

  <div class="case" data-name="a with quotes in title">
    <div class="input"><a href="http://example.com" title="&quot;hello&quot;">An anchor</a></div>
    <pre class="expected">[An anchor](http://example.com ""hello"")</pre>
  </div>

  <div class="case" data-name="a with parenthesis in query">
    <div class="input"><a href="http://example.com?(query)">An anchor</a></div>
    <pre class="expected">[An anchor](http://example.com?(query))</pre>
  </div>

  <div class="case" data-name="a without a src">
    <div class="input"><a id="about-anchor">Anchor without a title</a></div>
    <pre class="expected">Anchor without a title</pre>
  </div>

  <div class="case" data-name="a with a child">
    <div class="input"><a href="http://example.com/code">Some <code>code</code></a></div>
    <pre class="expected">[Some `code`](http://example.com/code)</pre>
  </div>

  <div class="case" data-name="a reference" data-options='{"linkStyle": "referenced"}'>
    <div class="input"><a href="http://example.com">Reference link</a></div>
    <pre class="expected">[Reference link][1]

  [1]: http://example.com</pre>
  </div>

  <div class="case" data-name="a reference with collapsed style" data-options='{"linkStyle": "referenced", "linkReferenceStyle": "collapsed"}'>
    <div class="input"><a href="http://example.com">Reference link with collapsed style</a></div>
    <pre class="expected">[Reference link with collapsed style][]

  [Reference link with collapsed style]: http://example.com</pre>
  </div>

  <div class="case" data-name="a reference with shortcut style" data-options='{"linkStyle": "referenced", "linkReferenceStyle": "shortcut"}'>
    <div class="input"><a href="http://example.com">Reference link with shortcut style</a></div>
    <pre class="expected">[Reference link with shortcut style]

  [Reference link with shortcut style]: http://example.com</pre>
  </div>

  <div class="case" data-name="pre/code block">
    <div class="input"><pre><code>def code_block
    # 42 &lt; 9001
    "Hello world!"
  end</code></pre></div>

    <pre class="expected">    def code_block
        # 42 < 9001
        "Hello world!"
      end</pre>
  </div>

  <div class="case" data-name="multiple pre/code blocks">
    <div class="input"><pre><code>def first_code_block
    # 42 &lt; 9001
    "Hello world!"
  end</code></pre>

  <p>next:</p>

  <pre><code>def second_code_block
    # 42 &lt; 9001
    "Hello world!"
  end</code></pre></div>

    <pre class="expected">    def first_code_block
        # 42 < 9001
        "Hello world!"
      end

  next:

      def second_code_block
        # 42 < 9001
        "Hello world!"
      end</pre>
  </div>

  <div class="case" data-name="pre/code block with multiple new lines">
    <div class="input"><div><pre><code>Multiple new lines


  should not be


  removed</code></pre></div></div>

    <pre class="expected">    Multiple new lines


      should not be


      removed</pre>
  </div>

  <div class="case" data-name="fenced pre/code block" data-options='{"codeBlockStyle": "fenced"}'>
    <div class="input">
      <pre><code>def a_fenced_code block; end</code></pre>
    </div>
    <pre class="expected">```
  def a_fenced_code block; end
  ```</pre>
  </div>

  <div class="case" data-name="pre/code block fenced with ~" data-options='{"codeBlockStyle": "fenced", "fence": "~~~"}'>
    <div class="input">
      <pre><code>def a_fenced_code block; end</code></pre>
    </div>
    <pre class="expected">~~~
  def a_fenced_code block; end
  ~~~</pre>
  </div>

  <div class="case" data-name="escaping ~~~">
    <div class="input">
      <pre>~~~ foo</pre>
    </div>
    <pre class="expected">~~~ foo</pre>
  </div>

  <div class="case" data-name="not escaping ~~~">
    <div class="input">A sentence containing ~~~</div>
    <pre class="expected">A sentence containing ~~~</pre>
  </div>

  <div class="case" data-name="fenced pre/code block with language" data-options='{"codeBlockStyle": "fenced"}'>
    <div class="input">
      <pre><code class="language-ruby">def a_fenced_code block; end</code></pre>
    </div>
    <pre class="expected">```ruby
  def a_fenced_code block; end
  ```</pre>
  </div>

  <div class="case" data-name="empty pre does not throw error">
    <div class="input">
      <pre></pre>
    </div>
    <pre class="expected"></pre>
  </div>

  <div class="case" data-name="ol">
    <div class="input">
      <ol>
        <li>Ordered list item 1</li>
        <li>Ordered list item 2</li>
        <li>Ordered list item 3</li>
      </ol>
    </div>
    <pre class="expected">1.  Ordered list item 1
  2.  Ordered list item 2
  3.  Ordered list item 3</pre>
  </div>

  <div class="case" data-name="ol with start">
    <div class="input">
      <ol start="42">
        <li>Ordered list item 42</li>
        <li>Ordered list item 43</li>
        <li>Ordered list item 44</li>
      </ol>
    </div>
    <pre class="expected">42.  Ordered list item 42
  43.  Ordered list item 43
  44.  Ordered list item 44</pre>
  </div>

  <div class="case" data-name="list spacing">
    <div class="input">
      <p>A paragraph.</p>
      <ol>
        <li>Ordered list item 1</li>
        <li>Ordered list item 2</li>
        <li>Ordered list item 3</li>
      </ol>
      <p>Another paragraph.</p>
      <ul>
        <li>Unordered list item 1</li>
        <li>Unordered list item 2</li>
        <li>Unordered list item 3</li>
      </ul>
    </div>
    <pre class="expected">A paragraph.

  1.  Ordered list item 1
  2.  Ordered list item 2
  3.  Ordered list item 3

  Another paragraph.

  *   Unordered list item 1
  *   Unordered list item 2
  *   Unordered list item 3</pre>
  </div>

  <div class="case" data-name="ul">
    <div class="input">
      <ul>
        <li>Unordered list item 1</li>
        <li>Unordered list item 2</li>
        <li>Unordered list item 3</li>
      </ul>
    </div>
    <pre class="expected">*   Unordered list item 1
  *   Unordered list item 2
  *   Unordered list item 3</pre>
  </div>

  <div class="case" data-name="ul with custom bullet" data-options='{"bulletListMarker": "-"}'>
    <div class="input">
      <ul>
        <li>Unordered list item 1</li>
        <li>Unordered list item 2</li>
        <li>Unordered list item 3</li>
      </ul>
    </div>
    <pre class="expected">-   Unordered list item 1
  -   Unordered list item 2
  -   Unordered list item 3</pre>
  </div>

  <div class="case" data-name="ul with paragraph">
    <div class="input">
      <ul>
        <li><p>List item with paragraph</p></li>
        <li>List item without paragraph</li>
      </ul>
    </div>
    <pre class="expected">*   List item with paragraph

  *   List item without paragraph</pre>
  </div>

  <div class="case" data-name="ol with paragraphs">
    <div class="input">
      <ol>
        <li>
          <p>This is a paragraph in a list item.</p>
          <p>This is a paragraph in the same list item as above.</p>
        </li>
        <li>
          <p>A paragraph in a second list item.</p>
        </li>
      </ol>
    </div>
    <pre class="expected">1.  This is a paragraph in a list item.

      This is a paragraph in the same list item as above.

  2.  A paragraph in a second list item.</pre>
  </div>

  <div class="case" data-name="nested uls">
    <div class="input">
      <ul>
        <li>This is a list item at root level</li>
        <li>This is another item at root level</li>
        <li>
          <ul>
            <li>This is a nested list item</li>
            <li>This is another nested list item</li>
            <li>
              <ul>
                <li>This is a deeply nested list item</li>
                <li>This is another deeply nested list item</li>
                <li>This is a third deeply nested list item</li>
              </ul>
            </li>
          </ul>
        </li>
        <li>This is a third item at root level</li>
      </ul>
    </div>
    <pre class="expected">*   This is a list item at root level
  *   This is another item at root level
  *   *   This is a nested list item
      *   This is another nested list item
      *   *   This is a deeply nested list item
          *   This is another deeply nested list item
          *   This is a third deeply nested list item
  *   This is a third item at root level</pre>
  </div>

  <div class="case" data-name="nested ols and uls">
    <div class="input">
      <ul>
        <li>This is a list item at root level</li>
        <li>This is another item at root level</li>
        <li>
          <ol>
            <li>This is a nested list item</li>
            <li>This is another nested list item</li>
            <li>
              <ul>
                <li>This is a deeply nested list item</li>
                <li>This is another deeply nested list item</li>
                <li>This is a third deeply nested list item</li>
              </ul>
            </li>
          </ol>
        </li>
        <li>This is a third item at root level</li>
      </ul>
    </div>
    <pre class="expected">*   This is a list item at root level
  *   This is another item at root level
  *   1.  This is a nested list item
      2.  This is another nested list item
      3.  *   This is a deeply nested list item
          *   This is another deeply nested list item
          *   This is a third deeply nested list item
  *   This is a third item at root level</pre>
  </div>

  <div class="case" data-name="ul with blockquote">
    <div class="input">
      <ul>
        <li>
          <p>A list item with a blockquote:</p>
          <blockquote>
            <p>This is a blockquote inside a list item.</p>
          </blockquote>
        </li>
      </ul>
    </div>
    <pre class="expected">*   A list item with a blockquote:

      > This is a blockquote inside a list item.</pre>
  </div>

  <div class="case" data-name="blockquote">
    <div class="input">
      <blockquote>
        <p>This is a paragraph within a blockquote.</p>
        <p>This is another paragraph within a blockquote.</p>
      </blockquote>
    </div>
    <pre class="expected">> This is a paragraph within a blockquote.
  >
  > This is another paragraph within a blockquote.</pre>
  </div>

  <div class="case" data-name="nested blockquotes">
    <div class="input">
      <blockquote>
        <p>This is the first level of quoting.</p>
        <blockquote>
          <p>This is a paragraph in a nested blockquote.</p>
        </blockquote>
        <p>Back to the first level.</p>
      </blockquote>
    </div>
    <pre class="expected">> This is the first level of quoting.
  >
  > > This is a paragraph in a nested blockquote.
  >
  > Back to the first level.</pre>
  </div>

  <div class="case" data-name="html in blockquote">
    <div class="input">
      <blockquote>
        <h2>This is a header.</h2>
        <ol>
          <li>This is the first list item.</li>
          <li>This is the second list item.</li>
        </ol>
        <p>A code block:</p>
        <pre><code>return 1 &lt; 2 ? shell_exec('echo $input | $markdown_script') : 0;</code></pre>
      </blockquote>
    </div>
    <pre class="expected">> This is a header.
  > -----------------
  >
  > 1.  This is the first list item.
  > 2.  This is the second list item.
  >
  > A code block:
  >
  >     return 1 < 2 ? shell_exec('echo $input | $markdown_script') : 0;</pre>
  </div>

  <div class="case" data-name="multiple divs">
    <div class="input">
      <div>A div</div>
      <div>Another div</div>
    </div>
    <pre class="expected">A div

  Another div</pre>
  </div>

  <div class="case" data-name="multiple divs">
    <div class="input">
      <div>A div</div>
      <div>Another div</div>
    </div>
    <pre class="expected">A div

  Another div</pre>
  </div>

  <div class="case" data-name="comment">
    <div class="input"><!-- comment --></div>
    <pre class="expected"></pre>
  </div>

  <div class="case" data-name="pre/code with comment">
    <div class="input">
      <pre ><code>Hello<!-- comment --> world</code></pre>
    </div>
    <pre class="expected">    Hello world</pre>
  </div>

  <div class="case" data-name="leading whitespace in heading">
    <div class="input"><h3>
      h3 with leading whitespace</h3></div>
    <pre class="expected">### h3 with leading whitespace</pre>
  </div>

  <div class="case" data-name="trailing whitespace in li">
    <div class="input">
      <ol>
        <li>Chapter One
          <ol>
            <li>Section One</li>
            <li>Section Two with trailing whitespace </li>
            <li>Section Three with trailing whitespace </li>
          </ol>
        </li>
        <li>Chapter Two</li>
        <li>Chapter Three with trailing whitespace  </li>
      </ol>
    </div>
    <pre class="expected">1.  Chapter One
      1.  Section One
      2.  Section Two with trailing whitespace
      3.  Section Three with trailing whitespace
  2.  Chapter Two
  3.  Chapter Three with trailing whitespace</pre>
  </div>

  <div class="case" data-name="multilined and bizarre formatting">
    <div class="input">
      <ul>
        <li>
          Indented li with leading/trailing newlines
        </li>
        <li>
          <strong>Strong with trailing space inside li with leading/trailing whitespace </strong> </li>
        <li>li without whitespace</li>
        <li> Leading space, text, lots of whitespace …
                            text
        </li>
      </ol>
    </div>
    <pre class="expected">*   Indented li with leading/trailing newlines
  *   **Strong with trailing space inside li with leading/trailing whitespace**
  *   li without whitespace
  *   Leading space, text, lots of whitespace … text</pre>
  </div>

  <div class="case" data-name="whitespace between inline elements">
    <div class="input">
      <p>I <a href="http://example.com/need">need</a> <a href="http://www.example.com/more">more</a> spaces!</p>
    </div>
    <pre class="expected">I [need](http://example.com/need) [more](http://www.example.com/more) spaces!</pre>
  </div>

  <div class="case" data-name="whitespace in inline elements">
    <div class="input">Text with no space after the period.<em> Text in em with leading/trailing spaces </em><strong>text in strong with trailing space </strong></div>
    <pre class="expected">Text with no space after the period. _Text in em with leading/trailing spaces_ **text in strong with trailing space**</pre>
  </div>

  <div class="case" data-name="whitespace in nested inline elements">
    <div class="input">Text at root <strong><a href="http://www.example.com">link text with trailing space in strong </a></strong>more text at root</div>
    <pre class="expected">Text at root **[link text with trailing space in strong](http://www.example.com)** more text at root</pre>
  </div>

  <div class="case" data-name="blank inline elements">
    <div class="input">
      Text before blank em … <em></em> text after blank em
    </div>
    <pre class="expected">Text before blank em … text after blank em</pre>
  </div>

  <div class="case" data-name="blank block elements">
    <div class="input">
      Text before blank div … <div></div> text after blank div
    </div>
    <pre class="expected">Text before blank div …

  text after blank div</pre>
  </div>

  <div class="case" data-name="blank inline element with br">
    <div class="input"><strong><br></strong></div>
    <pre class="expected"></pre>
  </div>

  <div class="case" data-name="whitespace between blocks">
    <div class="input"><div><div>Content in a nested div</div></div>
  <div>Content in another div</div></div>
    <pre class="expected">Content in a nested div

  Content in another div</pre>
  </div>

  <div class="case" data-name="escaping backslashes">
    <div class="input">backslash </div>
    <pre class="expected">backslash \\</pre>
  </div>

  <div class="case" data-name="escaping headings with #">
    <div class="input">### This is not a heading</div>
    <pre class="expected">### This is not a heading</pre>
  </div>

  <div class="case" data-name="not escaping # outside of a heading">
    <div class="input">#This is not # a heading</div>
    <pre class="expected">#This is not # a heading</pre>
  </div>

  <div class="case" data-name="escaping em markdown with *">
    <div class="input">To add emphasis, surround text with *. For example: *this is emphasis*</div>
    <pre class="expected">To add emphasis, surround text with *. For example: *this is emphasis*</pre>
  </div>

  <div class="case" data-name="escaping em markdown with _">
    <div class="input">To add emphasis, surround text with _. For example: _this is emphasis_</div>
    <pre class="expected">To add emphasis, surround text with _. For example: _this is emphasis_</pre>
  </div>

  <div class="case" data-name="not escaping within code">
    <div class="input"><pre><code>def this_is_a_method; end;</code></pre></div>
    <pre class="expected">    def this_is_a_method; end;</pre>
  </div>

  <div class="case" data-name="escaping strong markdown with *">
    <div class="input">To add strong emphasis, surround text with **. For example: **this is strong**</div>
    <pre class="expected">To add strong emphasis, surround text with **. For example: **this is strong**</pre>
  </div>

  <div class="case" data-name="escaping strong markdown with _">
    <div class="input">To add strong emphasis, surround text with __. For example: __this is strong__</div>
    <pre class="expected">To add strong emphasis, surround text with __. For example: __this is strong__</pre>
  </div>

  <div class="case" data-name="escaping hr markdown with *">
    <div class="input">* * *</div>
    <pre class="expected">* * *</pre>
  </div>

  <div class="case" data-name="escaping hr markdown with -">
    <div class="input">- - -</div>
    <pre class="expected">- - -</pre>
  </div>

  <div class="case" data-name="escaping hr markdown with _">
    <div class="input">_ _ _</div>
    <pre class="expected">_ _ _</pre>
  </div>

  <div class="case" data-name="escaping hr markdown without spaces">
    <div class="input">***</div>
    <pre class="expected">***</pre>
  </div>

  <div class="case" data-name="escaping hr markdown with more than 3 characters">
    <div class="input">* * * * *</div>
    <pre class="expected">* * * * *</pre>
  </div>

  <div class="case" data-name="escaping ol markdown">
    <div class="input">1984. by George Orwell</div>
    <pre class="expected">1984. by George Orwell</pre>
  </div>

  <div class="case" data-name="not escaping . outside of an ol">
    <div class="input">1984.George Orwell wrote 1984.</div>
    <pre class="expected">1984.George Orwell wrote 1984.</pre>
  </div>

  <div class="case" data-name="escaping ul markdown *">
    <div class="input">* An unordered list item</div>
    <pre class="expected">* An unordered list item</pre>
  </div>

  <div class="case" data-name="escaping ul markdown -">
    <div class="input">- An unordered list item</div>
    <pre class="expected">- An unordered list item</pre>
  </div>

  <div class="case" data-name="escaping ul markdown +">
    <div class="input">+ An unordered list item</div>
    <pre class="expected">+ An unordered list item</pre>
  </div>

  <div class="case" data-name="not escaping - outside of a ul">
    <div class="input">Hello-world, 45 - 3 is 42</div>
    <pre class="expected">Hello-world, 45 - 3 is 42</pre>
  </div>

  <div class="case" data-name="not escaping + outside of a ul">
    <div class="input">+1 and another +</div>
    <pre class="expected">+1 and another +</pre>
  </div>

  <div class="case" data-name="escaping *">
    <div class="input">You can use * for multiplication</div>
    <pre class="expected">You can use * for multiplication</pre>
  </div>

  <div class="case" data-name="escaping ** inside strong tags">
    <div class="input"><strong>**test</strong></div>
    <pre class="expected">****test**</pre>
  </div>

  <div class="case" data-name="escaping _ inside em tags">
    <div class="input"><em>test_italics</em></div>
    <pre class="expected">_test_italics_</pre>
  </div>

  <div class="case" data-name="escaping > as blockquote">
    <div class="input">> Blockquote in markdown</div>
    <pre class="expected">> Blockquote in markdown</pre>
  </div>

  <div class="case" data-name="escaping > as blockquote without space">
    <div class="input">>Blockquote in markdown</div>
    <pre class="expected">>Blockquote in markdown</pre>
  </div>

  <div class="case" data-name="not escaping > outside of a blockquote">
    <div class="input">42 > 1</div>
    <pre class="expected">42 > 1</pre>
  </div>

  <div class="case" data-name="escaping code">
    <div class="input">`not code`</div>
    <pre class="expected">`not code`</pre>
  </div>

  <div class="case" data-name="escaping []">
    <div class="input">[This] is a sentence with brackets</div>
    <pre class="expected">[This] is a sentence with brackets</pre>
  </div>

  <div class="case" data-name="escaping [">
    <div class="input"><a href="http://www.example.com">c[iao</a></div>
    <pre class="expected">[c[iao](http://www.example.com)</pre>
  </div>

  <!-- https://github.com/domchristie/to-markdown/issues/188#issuecomment-332216019 -->
  <div class="case" data-name="escaping * performance">
    <div class="input">fasdf *883 asdf wer qweasd fsd asdf asdfaqwe rqwefrsdf</div>
    <pre class="expected">fasdf *883 asdf wer qweasd fsd asdf asdfaqwe rqwefrsdf</pre>
  </div>

  <div class="case" data-name="escaping multiple asterisks">
    <div class="input"><p>* * ** It aims to be*</p></div>
    <pre class="expected">* * ** It aims to be*</pre>
  </div>

  <div class="case" data-name="escaping delimiters around short words and numbers">
    <div class="input"><p>_Really_? Is that what it _is_? A **2000** year-old computer?</p></div>
    <pre class="expected">_Really_? Is that what it _is_? A **2000** year-old computer?</pre>
  </div>

  <div class="case" data-name="non-markdown block elements">
    <div class="input">
      Foo
      <div>Bar</div>
      Baz
    </div>
    <pre class="expected">Foo

  Bar

  Baz</pre>
  </div>

  <div class="case" data-name="non-markdown inline elements">
    <div class="input">
      Foo <span>Bar</span>
    </div>
    <pre class="expected">Foo Bar</pre>
  </div>

  <div class="case" data-name="blank inline elements">
    <div class="input">
      Hello <em></em>world
    </div>
    <pre class="expected">Hello world</pre>
  </div>

  <div class="case" data-name="elements with a single void element">
    <div class="input">
      <p><img src="http://example.com/logo.png" /></p>
    </div>
    <pre class="expected">![](http://example.com/logo.png)</pre>
  </div>

  <div class="case" data-name="elements with a nested void element">
    <div class="input">
      <p><span><img src="http://example.com/logo.png" /></span></p>
    </div>
    <pre class="expected">![](http://example.com/logo.png)</pre>
  </div>

  <div class="case" data-name="text separated by a space in an element">
    <div class="input">
      <p>Foo<span> </span>Bar</p>
    </div>
    <pre class="expected">Foo Bar</pre>
  </div>

  <div class="case" data-name="text separated by a non-breaking space in an element">
    <div class="input">
      <p>Foo<span>&nbsp;</span>Bar</p>
    </div>
    <pre class="expected">Foo&nbsp;Bar</pre>
  </div>

  <div class="case" data-name="triple tildes inside code" data-options='{"codeBlockStyle": "fenced", "fence": "~~~"}'>
    <div class="input">
  <pre><code>~~~
  Code
  ~~~
  </code></pre>
    </div>
    <pre class="expected">~~~~
  ~~~
  Code
  ~~~
  ~~~~</pre>
  </div>

  <div class="case" data-name="triple ticks inside code" data-options='{"codeBlockStyle": "fenced", "fence": "```"}'>
    <div class="input">
  <pre><code>```
  Code
  ```
  </code></pre>
    </div>
    <pre class="expected">````
  ```
  Code
  ```
  ````</pre>
  </div>

  <div class="case" data-name="four ticks inside code" data-options='{"codeBlockStyle": "fenced", "fence": "```"}'>
    <div class="input">
  <pre><code>````
  Code
  ````
  </code></pre>
    </div>
    <pre class="expected">`````
  ````
  Code
  ````
  `````</pre>
  </div>

  <div class="case" data-name="empty line in start/end of code block" data-options='{"codeBlockStyle": "fenced", "fence": "```"}'>
    <div class="input">
  <pre><code>
  Code

  </code></pre>
    </div>
    <pre class="expected">```

  Code

  ```</pre>
  </div>

  <div class="case" data-name="text separated by ASCII and nonASCII space in an element">
    <div class="input">
      <p>Foo<span>  &nbsp;  </span>Bar</p>
    </div>
    <pre class="expected">Foo &nbsp; Bar</pre>
  </div>

  <div class="case" data-name="list-like text with non-breaking spaces">
    <div class="input">&nbsp;1. First<br>&nbsp;2. Second</div>
    <pre class="expected">&nbsp;1. First  <!-- hard break -->
  &nbsp;2. Second</pre>
  </div>

  <div class="case" data-name="element with trailing nonASCII WS followed by nonWS">
    <div class="input"><i>foo&nbsp;</i>bar</div>
    <pre class="expected">_foo_&nbsp;bar</pre>
  </div>

  <div class="case" data-name="element with trailing nonASCII WS followed by nonASCII WS">
    <div class="input"><i>foo&nbsp;</i>&nbsp;bar</div>
    <pre class="expected">_foo_&nbsp;&nbsp;bar</pre>
  </div>

  <div class="case" data-name="element with trailing ASCII WS followed by nonASCII WS">
    <div class="input"><i>foo </i>&nbsp;bar</div>
    <pre class="expected">_foo_ &nbsp;bar</pre>
  </div>

  <div class="case" data-name="element with trailing nonASCII WS followed by ASCII WS">
    <div class="input"><i>foo&nbsp;</i> bar</div>
    <pre class="expected">_foo_&nbsp; bar</pre>
  </div>

  <div class="case" data-name="nonWS followed by element with leading nonASCII WS">
    <div class="input">foo<i>&nbsp;bar</i></div>
    <pre class="expected">foo&nbsp;_bar_</pre>
  </div>

  <div class="case" data-name="nonASCII WS followed by element with leading nonASCII WS">
    <div class="input">foo&nbsp;<i>&nbsp;bar</i></div>
    <pre class="expected">foo&nbsp;&nbsp;_bar_</pre>
  </div>

  <div class="case" data-name="nonASCII WS followed by element with leading ASCII WS">
    <div class="input">foo&nbsp;<i> bar</i></div>
    <pre class="expected">foo&nbsp; _bar_</pre>
  </div>

  <div class="case" data-name="ASCII WS followed by element with leading nonASCII WS">
    <div class="input">foo <i>&nbsp;bar</i></div>
    <pre class="expected">foo &nbsp;_bar_</pre>
  </div>

  <!-- Behavior of `<code>` with CSS set as `white-space: pre-wrap;`, e.g. in GitLab -->
  <div class="case" data-name="preformatted code with leading whitespace" data-options='{"preformattedCode": true}'>
    <div class="input">Four spaces <code>    make an indented code block in Markdown</code></div>
    <pre class="expected">Four spaces `    make an indented code block in Markdown`</pre>
  </div>

  <div class="case" data-name="preformatted code with trailing whitespace" data-options='{"preformattedCode": true}'>
    <div class="input"><code>A line break  </code> <b> note the spaces</b></div>
    <pre class="expected">`A line break  ` **note the spaces**</pre>
  </div>

  <div class="case" data-name="preformatted code tightly surrounded" data-options='{"preformattedCode": true}'>
    <div class="input"><b>tight</b><code>code</code><b>wrap</b></div>
    <pre class="expected">**tight**`code`**wrap**</pre>
  </div>

  <div class="case" data-name="preformatted code loosely surrounded" data-options='{"preformattedCode": true}'>
    <div class="input"><b>not so tight </b><code>code</code><b> wrap</b></div>
    <pre class="expected">**not so tight** `code` **wrap**</pre>
  </div>

  <!-- newlines become spaces + extra space must be added  -->
  <div class="case" data-name="preformatted code with newlines" data-options='{"preformattedCode": true}'>
    <div class="input">
  <code>

   nasty
  code

  </code>
    </div>
    <pre class="expected">`    nasty code   `</pre>
  </div>

  <!-- /TEST CASES -->

  <script src="turndown-test.browser.js"></script>
  </body>
  </html>

HTML

turndown_service = TurndownService.new(heading_style: "atx")
markdown_output = turndown_service.turndown(html_input)

puts markdown_output
