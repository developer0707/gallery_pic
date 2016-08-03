attributes :id, :mention_start, :mention_end
child(:referenced_user, partial: 'users/base')
