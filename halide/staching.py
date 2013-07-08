""" stache module
    Compact implementation of the Mustache logic-less templating language
    
    
    
    This is fork of the Stache project. With much thanks to the author of the
    the original Stache, most of the code is from the orginal Stache project. 
    See:
       https://github.com/hyperturtle/Stache
       https://pypi.python.org/pypi/Stache/0.0.9
    
"""
__version__ = "0.0.2"
__author__ = "Samuel M. Smith"
__license__ =  "MIT"

import itertools
from cgi import escape


try:
    from sys import intern # python 3
except ImportError: 
    pass

_debug = False

TOKEN_RAW        = intern('raw')
TOKEN_TAGOPEN    = intern('tagopen')
TOKEN_TAGINVERT  = intern('taginvert')
TOKEN_TAGCLOSE   = intern('tagclose')
TOKEN_TAGCOMMENT = intern('tagcomment')
TOKEN_TAGDELIM   = intern('tagdelim')
TOKEN_TAG        = intern('tag')
TOKEN_PARTIAL    = intern('partial')
TOKEN_PUSH       = intern('push')
TOKEN_BOOL       = intern('bool')

def _checkprefix(tag, prefix):
    return tag[1:].strip() if tag and tag[0] == prefix else None

def _lookup(data, datum):
    for scope in data:
        if datum == '.':
            return str(scope)
        elif datum in scope:
            return scope[datum]
        elif hasattr(scope, datum):
            return getattr(scope, datum)
    return None

def render(template, data):
    return Stache().render(template, data)

class Stache(object):
    def __init__(self):
        self.otag = '{{'
        self.ctag = '}}'
        self.templates = {}
        self.hoist = {}
        self.hoist_data = {}
        self.section_counter = 0

    def copy(self):
        copy = Stache()
        copy.templates = self.templates
        return copy

    def add_template(self, name, template):
        self.templates[name] = list(self._tokenize(template))

    def render(self, template, data={}):
        self.otag = '{{'
        self.ctag = '}}'
        return ''.join(self._parse(self._tokenize(template), data))

    def render_iter(self, template, data={}):
        copy = self.copy()
        return copy._parse(copy._tokenize(template), data)

    def render_template(self, template_name, data={}):
        self.otag = '{{'
        self.ctag = '}}'
        return ''.join(self._parse(iter(list(self.templates[template_name])), data))

    def render_template_iter(self, template_name, data={}):
        copy = self.copy()
        return copy._parse(iter(list(copy.templates[template_name])), data)

    def _tokenize(self, template):
        rest  = template
        scope = []

        while rest and len(rest) > 0:
            pre_section    = rest.split(self.otag, 1)
            pre, rest      = pre_section if len(pre_section) == 2 else (pre_section[0], None)
            if _debug: print "pre: \n%s\nrest: \n%s" % (pre, rest)
            
            taglabel, rest = rest.split(self.ctag, 1) if rest else (None, None)
            taglabel       = taglabel.strip() if taglabel else ''
            if _debug: print "taglabel: \n%s\nrest: \n%s" % (taglabel, rest)
            
            open_tag       = _checkprefix(taglabel, '#')
            invert_tag     = _checkprefix(taglabel, '^') if not open_tag else None
            close_tag      = _checkprefix(taglabel, '/') if not invert_tag else None
            comment_tag    = _checkprefix(taglabel, '!') if not close_tag else None
            partial_tag    = _checkprefix(taglabel, '>') if not comment_tag else None
            push_tag       = _checkprefix(taglabel, '<') if not partial_tag else None
            bool_tag       = _checkprefix(taglabel, '?') if not push_tag else None
            booltern_tag   = _checkprefix(taglabel, ':') if not bool_tag else None
            unescape_tag   = _checkprefix(taglabel, '{') if not booltern_tag else None
            if unescape_tag:
                rest = rest[1:]
                #if _debug: print "unescape rest: \n%s" %  rest
            
            unescape_tag   = ((unescape_tag or _checkprefix(taglabel, '&'))
                              if not booltern_tag else None)
            delim_tag      = (taglabel[1:-1] if not unescape_tag and
                              len(taglabel) >= 2 and taglabel[0] == '='
                              and taglabel[-1] == '='
                              else None)
            delim_tag      = delim_tag.split(' ', 1) if delim_tag else None
            delim_tag      = delim_tag if delim_tag and len(delim_tag) == 2 else None
            
            if  (   open_tag or invert_tag or comment_tag or
                    partial_tag or push_tag or bool_tag or
                    booltern_tag or unescape_tag or delim_tag): # not a variable
                inline = False
                if rest: # strip trailing whitespace and linefeed if present
                    front, sep, back = rest.partition("\n") # partition at linefeed
                    if sep:
                        if not front.strip(): # only whitespace before linefeed
                            rest = back # removed whitespace and linefeed
                            #if _debug: print "open rest strip front: \n%s" %  rest
                        else: #inline
                            inline = True
                            #if _debug: print "open inline:"
                if not inline and pre: #strip trailing whitespace after linefeed if present
                    front, sep, back = pre.rpartition("\n")
                    if sep:
                        if not back.strip(): # only whitespace after linefeed
                            pre = ''.join((front, sep)) # restore linefeed
                            #if _debug: print "open pre strip back: \n%s" % pre
                    else:
                        pre = back.rstrip() #no linefeed so rstrip
                        #if _debug: print "open pre rstrip back: \n%s" % pre
                        
            elif close_tag:
                inline = True # section is inline
                follow = False # followed by inline
                post = '' 
                
                if rest: # see if inline follows
                    front, sep, back = rest.partition("\n")
                    if front.strip(): # not empty before linefeed so inline follows
                        follow = True # inline follows
                        #if _debug: print "close follow:"
                        
                if pre: #strip trailing whitespace after prev linefeed if present
                    front, sep, back = pre.rpartition("\n")
                    if sep and not back.strip(): # only whitespace after linefeed
                        inline = False
                        #if _debug: print "close not inline:"                        
                        if follow:
                            post = back # save spacing for following inline
                        pre = ''.join((front, sep)) # restore upto linefeed
                        #if _debug: print "close pre strip back: \n%s" % pre
                                                       
                if not inline and rest: # strip trailing whitespace and linefeed if present
                    if follow: # restore saved spacing
                        rest = post + rest
                        #print "close follow rest: \n%s" %  rest
                    front, sep, back = rest.partition("\n") # partition at linefeed
                    if sep:
                        if not front.strip(): # only whitespace before linefeed
                            rest = back # remove trailing whitespace and linefeed
                            #if _debug: print "close rest strip front: \n%s" %  rest
                        
            if push_tag:
                pre = pre.rstrip()
                rest = rest.lstrip()
                #if _debug: print "push rest: \n%s" %  rest
                
            if pre:
                yield TOKEN_RAW, pre, len(scope)  

            if open_tag:
                scope.append(open_tag)
                yield TOKEN_TAGOPEN, open_tag, len(scope)
            elif bool_tag:
                scope.append(bool_tag)
                yield TOKEN_BOOL, bool_tag, len(scope)
            elif invert_tag:
                scope.append(invert_tag)
                yield TOKEN_TAGINVERT, invert_tag, len(scope)
            elif close_tag is not None:
                current_scope = scope.pop()
                if close_tag:
                    assert (current_scope == close_tag), 'Mismatch open/close blocks'
                yield TOKEN_TAGCLOSE, current_scope, len(scope)+1
            elif booltern_tag:
                scope.append(booltern_tag)
                yield TOKEN_TAG, booltern_tag, 0
                yield TOKEN_TAGINVERT, booltern_tag, len(scope)
            elif comment_tag:
                yield TOKEN_TAGCOMMENT, comment_tag, 0
            elif partial_tag:
                yield TOKEN_PARTIAL, partial_tag, 0
            elif push_tag:
                scope.append(push_tag)
                yield TOKEN_PUSH, push_tag, len(scope)
            elif delim_tag:
                yield TOKEN_TAGDELIM, delim_tag, 0
            elif unescape_tag:
                yield TOKEN_TAG, unescape_tag, True
            else:
                yield TOKEN_TAG, taglabel, False

    def _parse(self, tokens, *data):
        for token in tokens:
            if _debug: print 'token:' + str(token)
            tag, content, scope = token
            if tag == TOKEN_RAW:
                yield str(content)
            elif tag == TOKEN_TAG:
                tagvalue = _lookup(data, content)
                #cant use if tagvalue because we need to render tagvalue if it's 0
                #testing if tagvalue == 0, doesnt work since False == 0
                if tagvalue is not None and tagvalue is not False:
                    try:
                        if len(tagvalue) > 0:
                            if scope:
                                yield str(tagvalue)
                            else:
                                yield escape(str(tagvalue))
                    except TypeError:
                        if scope:
                            yield str(tagvalue)
                        else:
                            yield escape(str(tagvalue))
            elif tag == TOKEN_TAGOPEN or tag == TOKEN_TAGINVERT:
                tagvalue = _lookup(data, content)
                untilclose = itertools.takewhile(lambda x: x != (TOKEN_TAGCLOSE, content, scope), tokens)
                if (tag == TOKEN_TAGOPEN and tagvalue) or (tag == TOKEN_TAGINVERT and not tagvalue):
                    if hasattr(tagvalue, 'items'):
                        #if _debug: print '    its a dict!', tagvalue, untilclose
                        for part in self._parse(untilclose, tagvalue, *data):
                            yield part
                    else:
                        try:
                            iterlist = list(iter(tagvalue))
                            if len(iterlist) == 0:
                                raise TypeError
                            
                            #from http://docs.python.org/library/itertools.html#itertools.tee
                            #In general, if one iterator uses most or all of the data before
                            #another iterator starts, it is faster to use list() instead of tee().
                            rest = list(untilclose)
                            #if _debug: print '    its a list!', list(rest)
                            for listitem in iterlist:
                                for part in self._parse(iter(rest), listitem, *data):
                                    yield part
                        except TypeError:
                            #if _debug: print '    its a bool!'
                            for part in self._parse(untilclose, *data):
                                yield part
                else:
                    for ignore in untilclose:
                        pass
            elif tag == TOKEN_BOOL:
                tagvalue = _lookup(data, content)
                untilclose = itertools.takewhile(lambda x: x != (TOKEN_TAGCLOSE, content, scope), tokens)
                if tagvalue:
                    for part in self._parse(untilclose, *data):
                        yield part
                else:
                    for part in untilclose:
                        pass
            elif tag == TOKEN_PARTIAL:
                if content in self.templates:
                    for part in self._parse(iter(list(self.templates[content])), *data):
                        yield part
            elif tag == TOKEN_PUSH:
                untilclose = itertools.takewhile(lambda x: x != (TOKEN_TAGCLOSE, content, scope), tokens)
                data[-1][content] = ''.join(self._parse(untilclose, *data))
            elif tag == TOKEN_TAGDELIM:
                self.otag, self.ctag = content

if __name__ == "__main__":
    """Process command line args """
    import argparse
    
    try:
        import simplejson as json
    except ImportError:
        import json
    
    d = "Renders template file given json data dict and store result in rendered file. "
    p = argparse.ArgumentParser(description = d)
    p.add_argument('-v','--verbose',
                     action = 'store_const',
                     const = True,
                     default = False,
                     help = "Verbose debug mode.")    
    p.add_argument('-t','--template',
                    action = 'store',
                    nargs='?', 
                    const = 'template.html',
                    default = 'template.html',
                    help = "Template file.")
    p.add_argument('-d','--data',
                    action = 'store',
                    nargs='?', 
                    const = 'data.json',
                    default = 'data.json',
                    help = "Data dict file in JSON.")
    p.add_argument('-r','--rendered',
                    action = 'store',
                    nargs='?', 
                    const = 'rendered.html',
                    default = 'rendered.html',
                    help = "Rendered file.")     
        
    args = p.parse_args()
    
    if args.verbose:
        _debug = True
        
    with  open(args.template, 'r') as fpt, open(args.data, 'r') as  fpd, open(args.rendered, 'w') as fpr:
        if _debug: print "Running staching"
        
        template = fpt.read()
        if _debug: print "Template: \n%s\n" % template
        
        data = json.load(fpd)
        if _debug: print "Data: \n%s\n" %  data
        
        if _debug: print "Rendering: ......"
        
        rendered = render(template, data)
        if _debug: print "Rendered: \n%s\n" % rendered
        
        fpr.write(rendered)
    
