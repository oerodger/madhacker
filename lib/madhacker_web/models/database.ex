# needed to get defdatabase and other macros
use Amnesia

# defines a database called Database, it's basically a defmodule with
# some additional magic
defdatabase Database do
  # this is just a forward declaration of the table, otherwise you'd have
  # to fully scope User.read in Message functions
  deftable User

  # this defines a table with other attributes as ordered set, and defines an
  # additional index as email, this improves lookup operations
  deftable User, [{ :id, autoincrement }, :name, :token], type: :ordered_set, index: [:token] do

    @type t :: %User{id: non_neg_integer, name: String.t, token: String.t}

    # def create_token(self) do
    #   %User{id: self.id, token: UUID.uuid1()} |> Message.write
    # end

    # def create_token!(self) do
    #   %User{id: self.id, token: UUID.uuid1()} |> Message.write!
    # end

  end
end
