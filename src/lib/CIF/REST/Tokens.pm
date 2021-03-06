package CIF::REST::Tokens;
use Mojo::Base 'Mojolicious::Controller';

sub index {
    my $self = shift;

    my $query      	= $self->param('q') || $self->param('observable');
    
    my $res = $self->cli->search({
        token      	=> $self->param('token'),
    });
    $self->stash(observables => $res, token => $self->param('token')); ##TODO is this safe?
    $self->respond_to(
        json    => { json => $res },
        html    => { template => 'tokens/index' },
    );
}

sub show {
    my $self  = shift;
    
    my $res = $self->cli->search({
        token      => $self->param('token'),
        id         => $self->stash->{'observable'},
    });
    $self->stash(observables => $res); ##TODO -- does this leak if we don't clear it?
    $self->respond_to(
        json    => { json => $res },
        html    => { template => 'observables/show' },
    );
}

sub create {
    my $self = shift;
    
    my $data = $self->req->json();
    
    ##TODO client should spin this out to a queue
    my $res = $self->cli->submit({
        token           => $self->param('token'),
        observables     => $data,
        enable_metadata => 1,
    });
    
    $self->res->headers->add('X-Location' => $self->req->url->to_string());
    $self->res->headers->add('X-Id' => @{$res}[0]); ## TODO

    $self->respond_to(
        json    => { json => $res, status => 201 },
    );
}

1;
